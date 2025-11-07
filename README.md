This project implements a **storage space simulator** in Assembly language, designed to emulate basic file system operations in both **unidimensional** and **bidimensional** memory models.

The simulator provides fundamental functionalities similar to those of a simple operating system’s memory manager:

- **Add** — allocate a new file in memory  
- **Get** — retrieve a stored file by its identifier or address  
- **Delete** — remove a file and free the occupied memory space  
- **Defragment** — reorganize memory to eliminate fragmentation and optimize space usage  

There are two main versions implemented:

1. **Task 1 — Unidimensional memory simulation**  
   Files are stored and managed within a linear (1D) memory model.

2. **Task 2 — Bidimensional memory simulation**  
   Memory is represented as a 2D matrix, simulating a more complex allocation and retrieval process.

---

The project also includes a **Python-based testing script** (`checker.py`) that automatically verifies the correctness of the assembly implementations.  
It runs a collection of predefined test cases (`.in` / `.out` files) for each functionality and computes a final score.
