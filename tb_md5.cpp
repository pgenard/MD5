#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmd5.h"

#define MAX_SIM_TIME 150

vluint64_t sim_time = 0;
int first_vector = 0;

int main(int argc, char** argv, char** env) {
  Verilated::commandArgs(argc, argv);
  
  Vmd5 *dut = new Vmd5;
  
  Verilated::traceEverOn(true);
  
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  
  dut->trace(m_trace, 5);
  m_trace->open("waveform.vcd");

  while (sim_time < MAX_SIM_TIME) {
    // Start
    if (sim_time == 1) {
      dut->nrst = 0;
      dut->start = 1;
      dut->enc = 1;

      dut->message[15] = 0x0;
      dut->message[14] = 0x000001b8;
      dut->message[13] = 0x80363534;
      dut->message[12] = 0x33323130;

      dut->message[11] = 0x66656463;
      dut->message[10] = 0x62613938;
      dut->message[9] = 0x37363534;
      dut->message[8] = 0x33323130;

      dut->message[7] = 0x66656463;
      dut->message[6] = 0x62613938;
      dut->message[5] = 0x37363534;
      dut->message[4] = 0x33323130;

      dut->message[3] = 0x66656463;
      dut->message[2] = 0x62613938;
      dut->message[1] = 0x37363534;
      dut->message[0] = 0x33323130;
      // dut->message[0] = 0x61; for "a"

      dut->length = 0x0;
      // dut->length = 0x08; for "a"
      dut->length = 0x01b8;
    }

    if (sim_time == 3) {
      dut->start = 0;
      dut->nrst = 1;
    }

    if (sim_time == 133) {
      printf("### TEST VECTORS ###\n");
      
      first_vector = (dut->hash[3] == 0xd41d8cd9) && (dut->hash[2] == 0x8f00b204) && (dut->hash[1] == 0xe9800998) && (dut->hash[0] == 0xecf8427e);

      if (first_vector) {
	printf("md5sum(\"\") = d41d8cd98f00b204e9800998ecf8427e\n");
      }
    }

    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // md5sum "" = d41d8cd98f00b204e9800998ecf8427e
    // md5sum "a" = 0cc175b9c0f1b6a831c399e269772661
    // md5sum "0123456789abcdef0123456789abcdef0123456789abcdef0123456" = d8ea71eb4d2af27f59a5316c971065e6
    // md5sum "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" = 4fe130598d47f17c19a7c493b4ce0cf1;
  }

  m_trace->close();
  
  delete dut;
  
  exit(EXIT_SUCCESS);
}
