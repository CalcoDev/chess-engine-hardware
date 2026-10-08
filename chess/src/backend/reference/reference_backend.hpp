#pragma once

#include "../backend.hpp"

class ReferenceBackend : public Backend {

public:
	ReferenceBackend();
	~ReferenceBackend() override;

	bool invert(bool input) override;

};
