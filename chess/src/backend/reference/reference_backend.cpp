#include "reference_backend.hpp"

ReferenceBackend::ReferenceBackend() {}

ReferenceBackend::~ReferenceBackend() = default;

bool ReferenceBackend::invert(bool input) {
	return !input;
}
