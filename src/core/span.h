#pragma once

#include <cstddef>

#if defined(__cpp_lib_span) && __cpp_lib_span >= 202002L
#include <span>
#else
#include <cuda/std/span>
namespace std {
    using cuda::std::span;
    using cuda::std::dynamic_extent;
}
#endif
