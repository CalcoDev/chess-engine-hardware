#pragma once

#include "../backend.hpp"

#include <memory>

class VerilatorBackend : public Backend {

public:
	VerilatorBackend();
	~VerilatorBackend() override;

	bool invert(bool value) override;

private:
	struct Impl;
	std::unique_ptr<Impl> _impl;

};

