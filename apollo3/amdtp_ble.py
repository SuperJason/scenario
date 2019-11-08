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
        print(params)

    def handleNotification(self, cHandle, data):
        # ... perhaps check cHandle
        # ... process 'data'
        print('cHandle: ' + str(cHandle))
        print('data: ' + str(data))

def scan_dev(name):
    params = {'name':name, 'dev':None}
    scanner = Scanner().withDelegate(ScanDelegate(params))
    devices = scanner.scan(10.0)

    if params['dev'] in devices:
        print(' device \'' + params['name'] + '\' is found')

    return params['dev']

def connect_dev(addr, addrtype):
    print('Connecting ' + addr)
    conn = Peripheral(addr, addrtype)
    print(addr + ": connected")
    conn.setDelegate(AmdtpDelegate('AmdtpDelegate params'))

    #services_dic = conn.getServices()
    #for service in services_dic:
    #    print('  service: ' + str(service.uuid))
    #    charac_dic = service.getCharacteristics()
    #    for charac in charac_dic:
    #        print('    charac: ' + str(charac.uuid))

    print(' ---------- Amdtp service below ----------')
    srv_rec_ch = None
    srv_snd_ch = None
    srv_ctrl_ch = None
    service = conn.getServiceByUUID('00002760-08c2-11e1-9073-0e8ac72e1011')
    chs = service.getCharacteristics()
    for ch in chs:
        print('    charac: ' + str(ch.uuid))
        print('            ' + ch.propertiesToString())
        print('            ' + str(ch.getHandle()))
        # properties: WRITE NO RESPONSE, Handle: 2050
        if str(ch.uuid) == '00002760-08c2-11e1-9073-0e8ac72e0011':
            srv_rec_ch = ch
        # properties: NOTIFY, Handle: 2052
        elif str(ch.uuid) == '00002760-08c2-11e1-9073-0e8ac72e0012':
            srv_snd_ch = ch
        # properties: WRITE NO RESPONSE, Handle: 2055
        elif str(ch.uuid) == '00002760-08c2-11e1-9073-0e8ac72e0013':
            srv_ctrl_ch = ch

    return conn, srv_rec_ch, srv_snd_ch, srv_ctrl_ch

def amdtp_packet(lenght, header, data):

    packet = np.zeros(lenght + 8, dtype=np.uint8)
    # Lenght
    packet[0:2] = np.array([(lenght + 4) & 0xff, ((lenght + 4) >> 8) & 0xff], dtype=np.uint8)
    # Header
    packet[2:4] = np.array([header & 0xff, (header >> 8) & 0xff], dtype=np.uint8)
    packet[4:4+lenght] = data[0:lenght]
    # CRC32
    crc32 = np.zeros(4, dtype=np.uint8)
    crc32_value = crc32_func(bytes(data)) ^ 0xffffffff
    crc32[3] = (crc32_value>>24) & 0xff
    crc32[2] = (crc32_value>>16) & 0xff
    crc32[1] = (crc32_value>>8) & 0xff
    crc32[0] = crc32_value & 0xff
    packet[lenght+4:lenght+8] = crc32

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

crc32_func = crcmod.mkCrcFun(0x104C11DB7, initCrc=0xffffffff, xorOut=0)

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
    connect_result = connect_dev(amdtp_dev_addr, amdtp_dev_addrtype)
    print(' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ')
    conn, amdtp_srv_rec_ch, amdtp_srv_snd_ch, amdtp_srv_ctrl_ch = connect_result

    length = 512
    amdtp_send(length, np.arange(length, dtype=np.uint8), amdtp_srv_rec_ch)
    while True:
        print('Waiting...')
        if conn.waitForNotifications(10.0):
            print('# handleNotification() was called')
            amdtp_send(length, np.arange(length, dtype=np.uint8), amdtp_srv_rec_ch)
            continue
            #break

        #print('waitForNotifications timeout!')

    conn.disconnect()


