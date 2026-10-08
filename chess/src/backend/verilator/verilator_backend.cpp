#include "verilator_backend.hpp"

#include <verilated.h>
#include "Vdemo_not.h"

struct VerilatorBackend::Impl {
    VerilatedContext context;
    Vdemo_not dut{&context};
};

VerilatorBackend::VerilatorBackend()
	: _impl(std::make_unique<Impl>()) {
}

VerilatorBackend::~VerilatorBackend() = default;

bool VerilatorBackend::invert(bool value) {
    _impl->dut.in_value = value;
    _impl->dut.eval();
    return static_cast<bool>(_impl->dut.out_value);
}
