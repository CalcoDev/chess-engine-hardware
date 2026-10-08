#pragma once

class Backend {
public:
	virtual ~Backend() = default;
	
	virtual bool invert(bool input) = 0;
};

