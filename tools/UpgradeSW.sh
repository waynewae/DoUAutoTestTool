# upgrade
adb reboot bootloader
fastboot -i 0x489 flash partition /home/arog/SW/VNA_1560/00WW/VNA-0-1560-gpt_both0.bin
fastboot -i 0x489 flash sbl1 /home/arog/SW/VNA_1560/00WW/VNA-0-1560-sbl1.mbn
fastboot -i 0x489 flash aboot /home/arog/SW/VNA_1560/00WW/VNA-0-1560-emmc_appsboot.mbn
fastboot -i 0x489 flash rpm /home/arog/SW/VNA_1560/00WW/VNA-0-1560-rpm.mbn
fastboot -i 0x489 flash tz /home/arog/SW/VNA_1560/00WW/VNA-0-1560-tz.mbn
fastboot -i 0x489 flash hwcfg /home/arog/SW/VNA_1560/00WW/VNA-0-1560-hwcfg.img
fastboot -i 0x489 flash dbi /home/arog/SW/VNA_1560/00WW/VNA-0-1560-sdi.mbn
fastboot -i 0x489 flash splash /home/arog/SW/VNA_1560/00WW/VNA-00WW-043-splash.img
fastboot -i 0x489 flash multisplash /home/arog/SW/VNA_1560/00WW/VNA-00WW-043-multi-splash.img
fastboot -i 0x489 erase DDR
fastboot -i 0x489 reboot-bootloader
fastboot -i 0x489 flash boot /home/arog/SW/VNA_1560/00WW/VNA-0-1560-0002-boot.img
fastboot -i 0x489 flash recovery /home/arog/SW/VNA_1560/00WW/VNA-0-1560-0002-recovery.img
fastboot -i 0x489 flash persist /home/arog/SW/VNA_1560/00WW/VNA-0-1560-0001-persist.img
fastboot -i 0x489 flash ftmboot /home/arog/SW/VNA_1560/00WW/VNA-0-2010-ftmboot.img
fastboot -i 0x489 flash ftmsys /home/arog/SW/VNA_1560/00WW/VNA-0-2010-ftmsys.img
fastboot -i 0x489 flash cda /home/arog/SW/VNA_1560/00WW/VNA-00WW-043-cda.img
fastboot -i 0x489 flash hidden /home/arog/SW/VNA_1560/00WW/VNA-0-0010-0001-hidden.img.ext4
fastboot -i 0x489 flash modem /home/arog/SW/VNA_1560/00WW/VNA-0-1560-NON-HLOS.bin
fastboot -i 0x489 flash system /home/arog/SW/VNA_1560/00WW/VNA-0-1560-0002-system.img
fastboot -i 0x489 flash systeminfo /home/arog/SW/VNA_1560/00WW/fver
fastboot -i 0x489 flash sutinfo /home/arog/SW/VNA_1560/00WW/VNA-00WW-001-sutinfo.img
fastboot -i 0x489 flash cust_nv /home/arog/SW/VNA_1560/00WW/VNA-039-NV_cust.mbn
fastboot -i 0x489 erase userdata
fastboot -i 0x489 erase cache

echo Update Complete
echo Reboot
# reboot
fastboot -i 0x489 reboot
echo "Please do following action:"
echo "1. Set default configuration"
echo "2. Set device"
echo "3. Enable USB debugging"
echo "4. Disable screen lock"
echo "5. Make sleep mode to Never Timeout"
echo "6. Disable Power Monitor"
echo "7. Connect to the same AP wit PC"
adb wait-for-device
sleep 30
echo ""
echo Reboot complete
echo ""