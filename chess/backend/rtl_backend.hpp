#pragma once

#include <memory>

class RtlBackend {
public:
	RtlBackend();
	~RtlBackend();

	bool invert(bool value);

private:
	struct Impl;
	std::unique_ptr<Impl> _impl;
};

