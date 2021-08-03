#include <iostream>

int main() {
  int *p = nullptr;
  // This is an intentional bug, to test static analysis.
  std::cout << *p << std::endl;
  return 1;
}