#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Communiate to apollo3 with ble amdtp
"""

from bluepy.btle import Scanner, DefaultDelegate, Peripheral
import numpy as np
import crcmod

class ScanDelegate(DefaultDelegate):
    def __init__(self, params):
        DefaultDelegate.__init__(self)
        self.count = 0
        self.params = params

    def handleDiscovery(self, dev, isNewDev, isNewData):
        if isNewDev:
            self.count += 1
            print(' -- %d devices is found --'%self.count, end='\r')
            for (adtype, desc, value) in dev.getScanData():
                if desc == 'Complete Local Name':
                    print(' Name as \'%s\' device is found'%(value))
                    if self.params['name'] == value:
                        self.params['dev'] = dev

class AmdtpDelegate(DefaultDelegate):
    def __init__(self, params):
        DefaultDelegate.__init__(self)
        # ... initialise here
        self.hd = params

    def handleNotification(self, cHandle, data):
        self.hd['handle'] = cHandle
        self.hd['data'] = data

crc32_func = crcmod.mkCrcFun(0x104C11DB7, initCrc=0xffffffff, xorOut=0)

def scan_dev(name):
    params = {'name':name, 'dev':None}
    scanner = Scanner().withDelegate(ScanDelegate(params))
    devices = scanner.scan(10.0)

    if params['dev'] in devices:
        print(' device \'' + params['name'] + '\' is found')

    return params['dev']

def connect_dev(addr, addrtype):
    conn_handle = {'conn':None, 'rx_ch':None, 'tx_ch':None, 'ctrl_ch':None, 'nf_handle':None}

    print('Connecting ' + addr)
    conn = Peripheral(addr, addrtype)
    print(addr + ": connected")
    conn_handle['conn'] = conn

    nf_handle = {'handle':None, 'data':None}
    conn.setDelegate(AmdtpDelegate(nf_handle))
    conn_handle['nf_handle'] = nf_handle

    #services_dic = conn.getServices()
    #for service in services_dic:
    #    print('  service: ' + str(service.uuid))
    #    charac_dic = service.getCharacteristics()
    #    for charac in charac_dic:
    #        print('    charac: ' + str(charac.uuid))

    print(' ---------- Amdtp service below ----------')
    service = conn.getServiceByUUID('00002760-08c2-11e1-9073-0e8ac72e1011')
    chs = service.getCharacteristics()
    for ch in chs:
        print('    charac: ' + str(ch.uuid))
        print('            ' + ch.propertiesToString())
        print('            ' + str(ch.getHandle()))
        # properties: WRITE NO RESPONSE, Handle: 2050
        if str(ch.uuid) == '00002760-08c2-11e1-9073-0e8ac72e0011':
            conn_handle['rx_ch'] = ch
        # properties: NOTIFY, Handle: 2052
        elif str(ch.uuid) == '00002760-08c2-11e1-9073-0e8ac72e0012':
            conn_handle['tx_ch'] = ch
        # properties: WRITE NO RESPONSE, Handle: 2055
        elif str(ch.uuid) == '00002760-08c2-11e1-9073-0e8ac72e0013':
            conn_handle['ctrl_ch'] = ch

    return conn_handle

def amdtp_packet(length, header, data):

    packet = np.zeros(length + 8, dtype=np.uint8)
    # Lenght
    packet[0:2] = np.array([(length + 4) & 0xff, ((length + 4) >> 8) & 0xff], dtype=np.uint8)
    # Header
    packet[2:4] = np.array([header & 0xff, (header >> 8) & 0xff], dtype=np.uint8)
    packet[4:4+length] = data[0:length]
    # CRC32
    crc32 = np.zeros(4, dtype=np.uint8)
    crc32_value = crc32_func(bytes(data)) ^ 0xffffffff
    crc32[3] = (crc32_value>>24) & 0xff
    crc32[2] = (crc32_value>>16) & 0xff
    crc32[1] = (crc32_value>>8) & 0xff
    crc32[0] = crc32_value & 0xff
    packet[length+4:length+8] = crc32

    return packet

def amdtp_send(length, data, ch):

    pkt_type = 1
    serial_number = 0
    enc = 0
    ack = 0

    header = ((pkt_type & 0x0f) << 12)
    header |= ((serial_number & 0x0f) << 8)
    header |= ((enc & 0x01) << 7)
    header |= ((ack & 0x01) << 6)

    pk = amdtp_packet(length, header, data)

    mtu_len = 20
    remain_data_len = length + 8
    sent_len = 0

    while remain_data_len > 0:
        if remain_data_len > mtu_len:
            payload = mtu_len
        elif remain_data_len > 0:
            payload = remain_data_len

        d = pk[sent_len:sent_len+payload]

        ch.write(bytes(d))

        sent_len += payload
        remain_data_len -= payload

def amdtp_packet_parse(nf_hd, rx_pkt):
    print('handle: %d(0x%x)'%(nf_hd['handle'], nf_hd['handle']))

    rx_data = nf_hd['data']
    rx_len = len(rx_data)
    print('data(%d): %s'%(rx_len, str(rx_data)))

    offset = 0
    if rx_pkt['pkt_rx_len'] == 0:
        rx_pkt['length'] = (rx_data[1] << 8) | rx_data[0]
        rx_pkt['header'] = (rx_data[3] << 8) | rx_data[2]
        rx_pkt['data'] = np.zeros(rx_pkt['length'], dtype=np.uint8)
        offset = 4
        rx_len -= 4

    pkt_rx_len = rx_pkt['pkt_rx_len']
    rx_pkt['data'][pkt_rx_len:pkt_rx_len+rx_len] = np.frombuffer(rx_data[offset:offset+rx_len],dtype=np.uint8)
    rx_pkt['pkt_rx_len'] += rx_len

    #print('pkt_length: %d'%(rx_pkt['length']))
    #print('pkt_rx_len: %d'%(rx_pkt['pkt_rx_len']))
    #print('rx_len: %d'%(rx_len))

    if rx_pkt['pkt_rx_len'] == rx_pkt['length']:
        rx_pkt['crc32'] = rx_pkt['data'][-4]
        rx_pkt['crc32'] |= (rx_pkt['data'][-3] << 8)
        rx_pkt['crc32'] |= (rx_pkt['data'][-2] << 16)
        rx_pkt['crc32'] |= (rx_pkt['data'][-1] << 24)
        crc32_value = crc32_func(bytes(rx_pkt['data'][:-4])) ^ 0xffffffff
        if crc32_value != rx_pkt['crc32']:
            print('### Crc32 Error!')
            print('### package rx crc32: 0x%x'%rx_pkt['crc32'])
            print('### package data crc32: 0x%x'%crc32_value)

        pkt_type = (rx_pkt['header'] >> 12) & 0xf
        serial_number = (rx_pkt['header'] >> 8) & 0xf
        enc = (rx_pkt['header'] >> 7) & 0x1
        ack = (rx_pkt['header'] >> 6) & 0x1
        print(' ----- Package is received -----')
        print(' -- len: %d, type: %d, sn: %d, enc: %d, ack: %d'%(rx_pkt['length'], pkt_type, serial_number, enc, ack))
        print(' -- data: ' + str(rx_pkt['data'][:-4]))
        print(' -- crc32: 0x%x'%rx_pkt['crc32'])
    elif rx_pkt['pkt_rx_len'] > rx_pkt['length']:
        print('### Pacage RX error!')
        print('### pkt_length: %d'%(rx_pkt['length']))
        print('### pkt_rx_len: %d'%(rx_pkt['pkt_rx_len']))

if __name__ == '__main__':
    scan_dev_name = 'Amdtp'
    dev = None
    #dev = scan_dev(scan_dev_name)
    if dev != None:
        print('Found device in scan whoes name is ' + scan_dev_name)
        print('  addr: ' + dev.addr)
        print('  AddrType: ' + dev.addrType)

    # if scan works fine, here should be
    # amdtp_dev_addr = dev.addr
    # amdtp_dev_addrType = dev.addrType
    amdtp_dev_addr = '06:05:04:4a:d2:04'
    amdtp_dev_addrtype = 'public'

    print(' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ')
    amdtp_conn_hd = connect_dev(amdtp_dev_addr, amdtp_dev_addrtype)
    print(' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ')

    rx_pkt = {'length':0, 'header':0, 'data':None, 'crc32':0, 'pkt_rx_len':0}

    length = 512
    while True:
        if rx_pkt['pkt_rx_len'] >= rx_pkt['length']:

            # precess received package here

            rx_pkt['length'] = 0
            rx_pkt['header'] = 0
            rx_pkt['data'] = None
            rx_pkt['crc32'] = 0
            rx_pkt['pkt_rx_len'] = 0
            amdtp_send(length, np.arange(length, dtype=np.uint8), amdtp_conn_hd['rx_ch'])

        print('Waiting...')
        if amdtp_conn_hd['conn'].waitForNotifications(3.0):
            amdtp_packet_parse(amdtp_conn_hd['nf_handle'], rx_pkt)
            continue

        print('waitForNotifications timeout!')
        break

    amdtp_conn_hd['conn'].disconnect()


