import logging
from src.Parser import LogParser

# Silence logging during tests to keep the console clean
logging.disable(logging.CRITICAL)

def test_xml_logic_suite():
    parser = LogParser()
    print("Starting Parser Test Suite...\n")

    # --- Test Case 1: Basic Parsing (BasicTest.xml) ---
    print("Test 1: Basic XML Parsing...")
    res1 = parser.parse("Tests/MultiIDFilter.xml")
    assert res1["summary"]["total"] == 3
    print(" Passed: Basic parsing and record counting.")
    
    # --- Test Case 2: ID Filtering (MultiIDFilter.xml) ---
    print("Test 2: Event ID Filtering...")
    # Reset parser state for new test
    parser = LogParser() 
    res2 = parser.parse("Tests/MultiIDFilter.xml", target_ids=[1000])
    assert res2["summary"]["total"] == 1
    assert res2["data"][0]["event_id"] == 1000
    # Ensure ID 3000 and 4000 were dropped
    assert all(item["event_id"] == 1000 for item in res2["data"])
    print(" Passed: Event ID filtering logic.")

    # --- Test Case 3: Time Filtering (TimeRange.xml) ---
    print("Test 3: Timestamp Filtering...")
    parser = LogParser()
    # Filter for logs ONLY in 2026
    res3 = parser.parse("Tests/TimeRange.xml", since_str="2026-01-01 00:00")
    assert res3["summary"]["total"] == 2
    # Verify the oldest log (Dec 2025) was excluded
    for entry in res3["data"]:
        assert "2025" not in entry["timestamp"]
    print(" Passed: Chronological cutoff logic.")

    # --- Test Case 4: Robustness (MalformedEdgeCase.xml) ---
    print("Test 4: Edge Case & Malformed Handling...")
    parser = LogParser()
    res4 = parser.parse("Tests/MalformedEdgeCase.xml")
    # Test high-precision timestamp parsing doesn't crash
    assert res4["summary"]["total"] == 2
    # Test empty <Data/> tag normalization
    empty_msg_record = next(item for item in res4["data"] if item["event_id"] == 9999)
    assert empty_msg_record["message"] == "N/A"
    print(" Passed: Edge case normalization (Empty tags & High-res time).")

    print("\n" + "="*30)
    print("  ALL TESTS PASSED SUCCESSFULLY")
    print("="*30)

if __name__ == "__main__":
    try:
        test_xml_logic_suite()
    except AssertionError as e:
        print(f" Test Failed: {e}")
    except Exception as e:
        print(f" Unexpected Error: {e}")