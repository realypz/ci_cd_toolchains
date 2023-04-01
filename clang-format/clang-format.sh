clang-format --version

# -style=file requires you append a .clang_format file under `/repo_to_check` (e.g. the hosted folder being moounted).
# For reference, see `clang-format/.clang-format`.
find /repo_to_check -iname *.h -o -iname *.hpp -o -iname *.c -o -iname *.cpp | xargs clang-format -i -style=file
