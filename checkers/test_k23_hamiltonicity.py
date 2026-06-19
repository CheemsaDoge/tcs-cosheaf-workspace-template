import unittest

from check_k23_hamiltonicity import run_check


class K23HamiltonicityCheckerTest(unittest.TestCase):
    def test_k23_is_connected_min_degree_two_and_non_hamiltonian(self) -> None:
        result = run_check()

        self.assertEqual(result["status"], "pass")
        self.assertTrue(result["graph"]["connected"])
        self.assertTrue(result["graph"]["simple"])
        self.assertEqual(result["graph"]["min_degree"], 2)
        self.assertEqual(result["hamiltonian_cycle_count"], 0)
        self.assertFalse(result["has_hamiltonian_cycle"])


if __name__ == "__main__":
    unittest.main()
