#!/bin/bash
nohup python3 report_relay.py > report_relay.log 2>&1 &
./hlds_linux -console -game cstrike -port ${ThisService_GamePort:-27015} +maxplayers ${ThisService_Slots:-32} +map ${ThisService_WorkingDirectory:-de_dust2} +exec server.cfg
