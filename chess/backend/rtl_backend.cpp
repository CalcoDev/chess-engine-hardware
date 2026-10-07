#include "rtl_backend.hpp"

#include <verilated.h>
#include "Vdemo_not.h"

struct RtlBackend::Impl {
	VerilatedContext context;
	Vdemo_not dut{&context};
};

RtlBackend::RtlBackend() : _impl(std::make_unique<Impl>()) { }
RtlBackend::~RtlBackend() = default;

bool RtlBackend::invert(bool value) {
	_impl->dut.in_value = value;
	_impl->dut.eval();
	return static_cast<bool>(_impl->dut.out_value);
}
