#include <iostream>
#include "VButton.h"
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

  auto tick = [&]() {
    dut->clk = 0;
    dut->eval();
    tfp->dump(time);
    time += 10;

    dut->clk = 1;
    dut->eval();
    tfp->dump(time);
    time += 10;
  };

  // --- Test 1: Short click (press for a few cycles, release before HALF_SEC) ---
  std::cout << "=== Test 1: Short click ===" << std::endl;

  // Idle for a few cycles
  for (int i = 0; i < 5; i++) tick();

  // Press button
  dut->raw_pressed = 1;
  for (int i = 0; i < 3; i++) tick();

  // Release before HALF_SEC
  dut->raw_pressed = 0;
  for (int i = 0; i < 20; i++) {
    tick();
    if (dut->click) std::cout << "  click detected at time " << time << std::endl;
  }

  // --- Test 2: Long hold (press and hold past HALF_SEC) ---
  std::cout << "=== Test 2: Long hold ===" << std::endl;

  // Press and hold for longer than HALF_SEC (10 cycles in sim)
  dut->raw_pressed = 1;
  for (int i = 0; i < 20; i++) {
    tick();
    if (dut->click) std::cout << "  click detected at time " << time << std::endl;
    if (dut->held)  std::cout << "  held detected at time " << time << std::endl;
  }

  // Release
  dut->raw_pressed = 0;
  for (int i = 0; i < 10; i++) {
    tick();
    if (dut->held) std::cout << "  held still active at time " << time << std::endl;
  }

  // --- Test 3: Very brief tap (1 cycle press) ---
  std::cout << "=== Test 3: Brief tap ===" << std::endl;

  dut->raw_pressed = 1;
  tick();
  dut->raw_pressed = 0;
  for (int i = 0; i < 20; i++) {
    tick();
    if (dut->click) std::cout << "  click detected at time " << time << std::endl;
  }

  // Let it settle
  for (int i = 0; i < 5; i++) tick();

  tfp->close();
  delete tfp;

  dut->final();
  delete dut;

  std::cout << "=== Done ===" << std::endl;
  return 0;
}
