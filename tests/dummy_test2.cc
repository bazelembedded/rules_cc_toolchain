#include <iostream>

int main() {
  static bool a = true;
  if (a) {
    std::cout << "A" << std::endl;
  } else {
    std::cout << "Not A" << std::endl;
  }
  return 0;
}