make_vhdl_prom m1.1h CPUROM_1.vhd
make_vhdl_prom m2.2h CPUROM_2.vhd
make_vhdl_prom 3j.3h CPUROM_3.vhd
make_vhdl_prom m4.4h CPUROM_4.vhd
make_vhdl_prom m5.5h CPUROM_5.vhd
make_vhdl_prom j6.6h CPUROM_6.vhd

make_vhdl_prom c1.1i VIDROM_0.vhd
make_vhdl_prom c2.2i VIDROM_1.vhd
make_vhdl_prom c3.3i VIDROM_2.vhd
make_vhdl_prom c4.4i VIDROM_3.vhd
make_vhdl_prom c5.5i VIDROM_4.vhd
make_vhdl_prom c6.6i VIDROM_5.vhd
make_vhdl_prom c7.7i VIDROM_6.vhd
make_vhdl_prom c8.8i VIDROM_7.vhd
make_vhdl_prom c9.9i VIDROM_8.vhd

copy /b s1.7a + s2.8a SNDROM.bin
make_vhdl_prom SNDROM.bin SNDROM.vhd

pause