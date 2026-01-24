
def check_braces(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    balance = 0
    for i, line in enumerate(lines):
        for char in line:
            if char == '{':
                balance += 1
            elif char == '}':
                balance -= 1
        
        # print balance after each line to see where it hits 0 unexpectedly
        if balance < 0:
            print(f"Error: balance < 0 at line {i+1}")
            return
        
        # Look for class _AdvancedVideoEditorPageState end
        # We know it starts at line 77.
        if i+1 > 77 and balance == 1:
             # This is a candidate for method boundary or class end
             pass
        elif i+1 > 77 and balance == 0:
             print(f"Class or file potentially closed at line {i+1}")

check_braces(r'c:\Users\Night Furry\StudioProjects\ClipFrame\lib\features\Video Editing\VideoEditing.dart')
