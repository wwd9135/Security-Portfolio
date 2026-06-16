# Using this to create and test our pyTest module.

import pytest
import src.main as mainfunctions

@pytest.fixture
def number():
    return 10

class TestMath:
    def test_double(self, number):
        result = number * 2
        assert result == 20

    def test_triple(self, number):
        result = number * 3
        assert result == 30
