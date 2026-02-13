#include <iostream>
#include "VButton.h"
#include "VButton___024root.h"
#include <verilated.h>
#include <verilated_vcd_c.h>

int main(int argc, const char ** argv, const char ** env) {
  Verilated::commandArgs(argc, argv);

  VButton * dut = new VButton;

  Verilated::traceEverOn(true);
  VerilatedVcdC * tfp = new VerilatedVcdC;
  dut->trace(tfp, 99);
  tfp->open("button.vcd");

  dut->clk = 0;
  dut->raw_pressed = 0;

  int time = 0;
  int cycle = 0;

  auto tick = [&]() {
    dut->clk = 0;
    dut->eval();
    tfp->dump(time);
    time += 10;

    dut->clk = 1;
    dut->eval();
    tfp->dump(time);
    time += 10;

    std::cout << "  cycle " << cycle
              << "  raw=" << (int)dut->raw_pressed
              << "  click=" << (int)dut->click
              << "  held=" << (int)dut->held
              << "  state=" << (int)dut->rootp->Button__DOT__state
              << "  cnt=" << (int)dut->rootp->Button__DOT__clk_cnt
              << std::endl;
    cycle++;
  };

  // --- Test 1: Short click (press 3 cycles, release before HALF_SEC) ---
  std::cout << "=== Test 1: Short click ===" << std::endl;
  for (int i = 0; i < 3; i++) tick();   // idle

  dut->raw_pressed = 1;
  for (int i = 0; i < 3; i++) tick();   // press

  dut->raw_pressed = 0;
  for (int i = 0; i < 15; i++) tick();  // release

  // --- Test 2: Long hold (press past HALF_SEC) ---
  std::cout << "\n=== Test 2: Long hold ===" << std::endl;
  dut->raw_pressed = 1;
  for (int i = 0; i < 20; i++) tick();

  dut->raw_pressed = 0;
  for (int i = 0; i < 5; i++) tick();

  // --- Test 3: Very brief tap (1 cycle) ---
  std::cout << "\n=== Test 3: Brief tap ===" << std::endl;
  dut->raw_pressed = 1;
  tick();
  dut->raw_pressed = 0;
  for (int i = 0; i < 10; i++) tick();

  tfp->close();
  delete tfp;
  dut->final();
  delete dut;

  std::cout << "\n=== Done ===" << std::endl;
  return 0;
}
