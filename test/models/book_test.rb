require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "should save book with valid name" do
    book = Book.new(name: "Valid Book Title")
    assert book.save, "Book should save with valid name"
  end

  test "should not save book with name longer than 32 characters" do
    long_name = "a" * 33  # 33 characters
    book = Book.new(name: long_name)
    assert_not book.save, "Book should not save with name longer than 32 characters"
    assert_includes book.errors[:name], "is too long (maximum is 32 characters)"
  end

  test "should save book with name exactly 32 characters" do
    exact_name = "a" * 32  # exactly 32 characters
    book = Book.new(name: exact_name)
    assert book.save, "Book should save with name exactly 32 characters"
  end

  test "should not save book with duplicate name" do
    book1 = Book.create!(name: "Unique Title")
    book2 = Book.new(name: "Unique Title")
    assert_not book2.save, "Book should not save with duplicate name"
    assert_includes book2.errors[:name], "has already been taken"
  end

  test "should not save book without name" do
    book = Book.new(name: nil)
    assert_not book.save, "Book should not save without name"
    assert_includes book.errors[:name], "can't be blank"
  end

  test "should not save book with empty name" do
    book = Book.new(name: "")
    assert_not book.save, "Book should not save with empty name"
    assert_includes book.errors[:name], "can't be blank"
  end
end
