#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generator: Lớp K17A1 - Lập trình Python & Web
Teacher: Phạm Thị Đào (phamthidaoskv@gmail.com)
Main student: Thái Anh Huy (anhhuy@gmail.com)
"""

import json
from datetime import datetime, timedelta

# ═══ FIXED IDs ═══
TEACHER_ID  = '51e467a2-9033-5e85-b666-164ea075f6c9'
SCHOOL_ID   = 'a0000001-0000-0000-0000-000000000001'
CLASS_ID    = 'aa010001-0000-0000-0000-000000000001'
ANHHUY_ID   = 'b3e27ac4-a528-5174-92f8-99a8f273eb84'

ASSIGN_IDS  = [
    'ab010001-0000-0000-0000-000000000001',  # A1 - Python syntax
    'ab010002-0000-0000-0000-000000000002',  # A2 - Loops & Functions
    'ab010003-0000-0000-0000-000000000003',  # A3 - OOP midterm
    'ab010004-0000-0000-0000-000000000004',  # A4 - Web Flask
]
DIST_IDS = [
    'ac010001-0000-0000-0000-000000000001',
    'ac010002-0000-0000-0000-000000000002',
    'ac010003-0000-0000-0000-000000000003',
    'ac010004-0000-0000-0000-000000000004',
]

# 16 students
STUDENTS = [
    ('b3e27ac4-a528-5174-92f8-99a8f273eb84', 'Thái Anh Huy'),
    ('e274bfde-ca3f-56f8-a803-6008bbdbc1e5', 'Bùi Đình Anh'),
    ('13d565a8-ccb5-56fe-a884-30df48099615', 'Bùi Quang Linh'),
    ('2154f53c-8e69-551b-8c0d-5a2457b15fd8', 'Bùi Quang Minh'),
    ('0009cad5-6c63-5cc3-9596-dd0ed89ac948', 'Cao Cường'),
    ('d0318e10-3203-5130-9992-fba4053f5edb', 'Cao Đức Anh Quân'),
    ('5cbaae02-acd6-5121-83b2-f76819103ad2', 'Cao Việt Hoàng'),
    ('c8778c6b-7099-5c09-916c-6b0dabafde41', 'Đặng Bảo Anh'),
    ('f32ec038-e7de-5900-9f8e-399dcbc4a904', 'Đặng Huỳnh Quang'),
    ('98f08d80-eff4-5335-a524-036c8f213890', 'Đào Bình Phước'),
    ('24ed3ce4-4a9a-53d4-9b37-1606ac49dee4', 'Đào Duy Phúc'),
    ('c09e4f67-2386-5909-9adb-15bbbf6a191c', 'Đinh Hải Siêu'),
    ('1b091e49-228a-5e43-99ed-47ce336fbdb8', 'Đinh Lê Hoàng'),
    ('80cf60e4-7ba9-5658-9e3c-b232707d34b7', 'Đoàn Thanh Quang'),
    ('f6d81836-a646-586d-84fa-57cdbe0a6b16', 'Đồng Nguyên Hiếu'),
    ('192e7be4-9b8a-5a34-83a1-f04e6d292592', 'Dương Công Quốc Anh'),
]

def q_id(a, q): return f'00000000-0000-0000-0000-aa{a:04d}{q:06d}'
def ws_id(si, ai): return f'00000000-0000-0000-0000-bb{si:04d}{ai:06d}'
def sub_id(si, ai): return f'00000000-0000-0000-0000-cc{si:04d}{ai:06d}'
def sa_id(si, ai, qi): return f'00000000-0000-0000-0000-{si:04d}{ai:04d}{qi:04d}'
def ev_id(si, ai, qi): return f'00000000-0000-0000-0001-{si:04d}{ai:04d}{qi:04d}'

def jq(v): return json.dumps(v, ensure_ascii=False)

def ts(base, offset_days=0, hour=8, minute=0):
    d = datetime(2026, 1, 1) + timedelta(days=base + offset_days)
    return f"{d.year}-{d.month:02d}-{d.day:02d}T{hour:02d}:{minute:02d}:00+00:00"

lines = []
def w(*args): lines.extend(args)

# ═══════════════════════════════════════════════════
# ASSIGNMENT DEFINITIONS
# ═══════════════════════════════════════════════════
# Each question: (type, text, choices, correct_choice_id, points)
# choices: list of (id, text) — id is INT 0-based
# For essay/short_answer: choices=None, correct_choice_id=None

ASSIGNMENTS_DEF = [
    {
        'id': ASSIGN_IDS[0],
        'title': 'Kiểm tra 15 phút - Cú pháp Python cơ bản',
        'description': 'Bài kiểm tra nhanh về cú pháp Python: kiểu dữ liệu, toán tử, hàm cơ bản.',
        'total_points': 10,
        'dist_id': DIST_IDS[0],
        'available': 38,   # day offset from 2026-01-01
        'due': 39,
        'time_limit': 15,
        'status': 'closed',
        'questions': [
            ('multiple_choice', 'Trong Python, kiểu dữ liệu nào dùng để lưu trữ chuỗi ký tự?',
             [(0,'int'),(1,'float'),(2,'str'),(3,'char')], 2, 1.0),
            ('multiple_choice', 'Lệnh nào dùng để in dữ liệu ra màn hình trong Python?',
             [(0,'echo'),(1,'print()'),(2,'console.log()'),(3,'write()')], 1, 1.0),
            ('multiple_choice', 'Biểu thức 10 // 3 trong Python trả về kết quả nào?',
             [(0,'3'),(1,'3.33'),(2,'1'),(3,'3.0')], 0, 1.0),
            ('multiple_choice', 'Từ khóa nào dùng để khai báo hàm trong Python?',
             [(0,'def'),(1,'function'),(2,'func'),(3,'void')], 0, 1.0),
            ('multiple_choice', 'Kiểu dữ liệu nào KHÔNG tồn tại trong Python?',
             [(0,'list'),(1,'tuple'),(2,'char'),(3,'dict')], 2, 1.0),
            ('multiple_choice', '[x**2 for x in range(5)] trả về danh sách nào?',
             [(0,'[1,4,9,16,25]'),(1,'[0,1,2,3,4]'),(2,'[0,1,4,9,16]'),(3,'[1,2,3,4,5]')], 2, 1.0),
            ('multiple_choice', 'Toán tử nào tính phần dư của phép chia trong Python?',
             [(0,'//'),(1,'%'),(2,'**'),(3,'/')], 1, 1.0),
            ('multiple_choice', 'x = [1,2,3,4,5]. Giá trị của x[-1] là bao nhiêu?',
             [(0,'5'),(1,'1'),(2,'-1'),(3,'4')], 0, 1.0),
            ('multiple_choice', 'x=[1,2,3]; y=x; y.append(4). Giá trị của x sau đó là gì?',
             [(0,'[1,2,3]'),(1,'[4,1,2,3]'),(2,'[1,2,3,4]'),(3,'Error')], 2, 1.0),
            ('multiple_choice', 'Method nào dùng để thêm một phần tử vào cuối list trong Python?',
             [(0,'push()'),(1,'append()'),(2,'add()'),(3,'insert()')], 1, 1.0),
        ]
    },
    {
        'id': ASSIGN_IDS[1],
        'title': 'Bài tập: Vòng lặp và Hàm trong Python',
        'description': 'Kiểm tra kiến thức về vòng lặp for/while, hàm, tham số và giá trị trả về.',
        'total_points': 10,
        'dist_id': DIST_IDS[1],
        'available': 52,
        'due': 54,
        'time_limit': 45,
        'status': 'closed',
        'questions': [
            ('multiple_choice', 'Vòng lặp nào trong Python dùng để lặp qua từng phần tử của iterable?',
             [(0,'while'),(1,'for'),(2,'loop'),(3,'foreach')], 1, 1.0),
            ('multiple_choice', 'Giá trị mặc định của tham số hàm được định nghĩa ở đâu trong Python?',
             [(0,'Khi gọi hàm'),(1,'Trong khai báo hàm'),(2,'Trong thân hàm'),(3,'Ngoài hàm')], 1, 1.0),
            ('multiple_choice', 'Từ khóa nào dùng để trả về giá trị từ hàm Python?',
             [(0,'output'),(1,'return'),(2,'send'),(3,'result')], 1, 1.0),
            ('multiple_choice', 'Lệnh break trong vòng lặp Python có tác dụng gì?',
             [(0,'Bỏ qua iteration hiện tại'),(1,'Dừng toàn bộ vòng lặp'),(2,'Tiếp tục iteration kế tiếp'),(3,'Khởi tạo lại vòng lặp')], 1, 1.0),
            ('short_answer', 'Viết một hàm Python tên là sum_n(n) trả về tổng các số tự nhiên từ 1 đến n.',
             None, None, 2.0),
            ('essay', 'Viết chương trình Python in ra dãy Fibonacci đến n phần tử (nhập từ bàn phím). '
             'Giải thích rõ thuật toán, xử lý trường hợp đặc biệt n<=0 và trình bày code rõ ràng.',
             None, None, 4.0),
        ]
    },
    {
        'id': ASSIGN_IDS[2],
        'title': 'Kiểm tra Giữa kỳ - Lập trình Hướng đối tượng Python',
        'description': 'Đánh giá toàn diện kiến thức OOP: class, object, inheritance, encapsulation, polymorphism.',
        'total_points': 20,
        'dist_id': DIST_IDS[2],
        'available': 66,
        'due': 68,
        'time_limit': 60,
        'status': 'closed',
        'questions': [
            ('multiple_choice', 'Trong Python OOP, từ khóa nào dùng để tạo class?',
             [(0,'object'),(1,'class'),(2,'struct'),(3,'type')], 1, 1.0),
            ('multiple_choice', 'Phương thức __init__ trong Python class được gọi khi nào?',
             [(0,'Khi xóa object'),(1,'Khi in object'),(2,'Khi tạo instance mới'),(3,'Khi so sánh object')], 2, 1.0),
            ('multiple_choice', 'self trong Python method đại diện cho?',
             [(0,'Class hiện tại'),(1,'Instance của class'),(2,'Parent class'),(3,'Module hiện tại')], 1, 1.0),
            ('multiple_choice', 'Kế thừa trong Python được định nghĩa như thế nào?',
             [(0,'class Child extends Parent'),(1,'class Child(Parent)'),(2,'class Child inherits Parent'),(3,'class Child <- Parent')], 1, 1.0),
            ('multiple_choice', 'Để gọi method của class cha từ class con, ta dùng?',
             [(0,'parent.method()'),(1,'super().method()'),(2,'base.method()'),(3,'ancestor.method()')], 1, 1.0),
            ('multiple_choice', '__str__ method trong Python dùng để?',
             [(0,'So sánh 2 object'),(1,'Tính hash của object'),(2,'Định nghĩa biểu diễn string của object'),(3,'Copy object')], 2, 1.0),
            ('multiple_choice', 'Encapsulation (đóng gói) trong OOP là gì?',
             [(0,'Kế thừa thuộc tính'),(1,'Ẩn chi tiết nội bộ, chỉ expose interface'),(2,'Đa hình của method'),(3,'Tạo nhiều instance')], 1, 1.0),
            ('multiple_choice', 'Thuộc tính có tiền tố __ (double underscore) trong Python là?',
             [(0,'Public attribute'),(1,'Protected attribute'),(2,'Class attribute'),(3,'Private attribute (name mangling)')], 3, 1.0),
            ('multiple_choice', 'Polymorphism (đa hình) trong Python thể hiện qua?',
             [(0,'Class không thể có nhiều method'),(1,'Method override ở class con'),(2,'Chỉ có 1 cách gọi method'),(3,'Method không thể nhận tham số')], 1, 1.0),
            ('multiple_choice', '@property decorator trong Python dùng để?',
             [(0,'Tạo static method'),(1,'Định nghĩa class method'),(2,'Biến method thành thuộc tính có thể đọc'),(3,'Xóa thuộc tính')], 2, 1.0),
            ('multiple_choice', 'Class method trong Python được tạo bằng decorator nào?',
             [(0,'@staticmethod'),(1,'@classmethod'),(2,'@property'),(3,'@abstractmethod')], 1, 1.0),
            ('multiple_choice', 'Abstract class trong Python được hỗ trợ bởi module nào?',
             [(0,'collections'),(1,'typing'),(2,'abc'),(3,'inspect')], 2, 1.0),
            ('multiple_choice', 'Duck typing trong Python có nghĩa là?',
             [(0,'Chỉ dùng class có từ "duck"'),(1,'Kiểm tra type nghiêm ngặt'),(2,'Quan tâm behavior hơn type'),(3,'Không dùng OOP')], 2, 1.0),
            ('multiple_choice', 'Method __len__ trong Python được gọi khi?',
             [(0,'Dùng hàm len() trên object'),(1,'In object'),(2,'So sánh object'),(3,'Xóa object')], 0, 1.0),
            ('essay', 'Thiết kế class BankAccount với các thuộc tính: số tài khoản, chủ tài khoản, số dư. '
             'Cài đặt các method: nạp tiền, rút tiền (với validation), và in thông tin tài khoản. '
             'Áp dụng đúng nguyên tắc encapsulation.',
             None, None, 3.0),
            ('essay', 'Giải thích sự khác biệt giữa @classmethod và @staticmethod trong Python với ví dụ cụ thể. '
             'Khi nào nên dùng mỗi loại? Viết code minh họa cho cả hai.',
             None, None, 3.0),
        ]
    },
    {
        'id': ASSIGN_IDS[3],
        'title': 'Bài tập Web: HTML/CSS và Flask cơ bản',
        'description': 'Thực hành xây dựng web app đơn giản với Flask framework và HTML/CSS frontend.',
        'total_points': 10,
        'dist_id': DIST_IDS[3],
        'available': 82,
        'due': 86,
        'time_limit': 60,
        'status': 'active',
        'questions': [
            ('multiple_choice', 'Tag HTML nào dùng để tạo hyperlink (liên kết)?',
             [(0,'<link>'),(1,'<a>'),(2,'<href>'),(3,'<url>')], 1, 1.0),
            ('multiple_choice', 'Trong CSS, property nào thay đổi màu nền của element?',
             [(0,'color'),(1,'font-color'),(2,'background-color'),(3,'bg-color')], 2, 1.0),
            ('multiple_choice', 'Flask là gì trong Python?',
             [(0,'Thư viện xử lý database'),(1,'Micro web framework'),(2,'Testing framework'),(3,'Package manager')], 1, 1.0),
            ('multiple_choice', 'Decorator @app.route("/") trong Flask dùng để làm gì?',
             [(0,'Import module'),(1,'Khai báo biến global'),(2,'Gắn URL path với hàm xử lý'),(3,'Kết nối database')], 2, 1.0),
            ('short_answer', 'Viết route Flask đơn giản tại đường dẫn /hello trả về chuỗi "Xin chào, Flask!".',
             None, None, 2.0),
            ('essay', 'Xây dựng một ứng dụng Flask nhỏ có 2 route: trang chủ "/" hiển thị danh sách sinh viên '
             'và route "/student/<id>" hiển thị thông tin 1 sinh viên. Viết đầy đủ code Python và template HTML cơ bản. '
             'Giải thích cấu trúc project và cách Flask xử lý request.',
             None, None, 4.0),
        ]
    },
]

# ═══════════════════════════════════════════════════
# SCORE PROFILES
# Per student, per assignment: (mc_wrong_list, essay_scores_list)
# mc_wrong_list: list of 0-based question indices in MC questions to get wrong
# essay_scores_list: list of (ai_score, final_score) for essay/short_answer questions in order
# For A4: only 12 students submitted (4 haven't yet = still active)
# ═══════════════════════════════════════════════════

# Pattern tags for reporting diversity:
# anhhuy: improving → dip → strong recovery + grade override on A2 + late on A3
SCORE_PROFILES = {
    # sid: [
    #   (a1_wrong_qs, []),
    #   (a2_wrong_qs, [(short 0-2), (essay 0-4)]),
    #   (a3_wrong_qs, [(essay1 0-3), (essay2 0-3)]),
    #   (a4_wrong_qs, [(short 0-2), (essay 0-4)]) or None if not submitted
    # ]
    # note: mc question indices are within the MC questions of that assignment (0-based among MC qs)

    # s0: Thái Anh Huy - improving, dip at mid, strong recovery
    #   A1: 8/10, A2: 8/10 (AI 7.5 → GV override), A3: 11/20 (late), A4: 9/10
    's0': [
        ([6, 8], []),                              # A1: wrong q7,q9 → 8/10
        ([],     [(1.5, 1.5), (2.5, 3.0)]),        # A2: 4MC + 1.5short + AI2.5→GVoverride3.0 → 8.5→9?
        # Actually: 4MC correct, short 1.5, essay AI=2.5 GV=3 → total 4+1.5+3=8.5 → round to 8.5
        # Hmm let me redesign:
        # A2: wrong q2_2(idx1) → 3MC correct, short=1.5, essay AI=2.5 override to 3 → 3+1.5+3=7.5
        # Nah let me just keep track. I'll recompute below.
        ([6,7,8,9,10,11], [(1.5, 1.5), (1.5, 2.0)]),  # A3: wrong 6 MC, essay1 AI=1.5, essay2 AI=1.5 GV=2.0 → 8+1.5+2=11.5
        ([], [(2.0, 2.0), (3.0, 3.0)]),            # A4: all MC correct, short=2, essay=3 → 4+2+3=9
    ],
    # s1: Bùi Đình Anh - consistently high
    's1': [
        ([4], []),                                  # A1: 9/10
        ([],  [(2.0, 2.0), (3.5, 3.5)]),            # A2: 4+2+3.5=9.5
        ([0], [(2.5, 2.5), (2.5, 2.5)]),            # A3: 13+2.5+2.5=18
        ([],  [(2.0, 2.0), (3.5, 3.5)]),            # A4: 4+2+3.5=9.5
    ],
    # s2: Bùi Quang Linh - consistently weak
    's2': [
        ([1,3,4,6,8], []),                          # A1: 5/10
        ([0,2],       [(1.0, 1.0), (1.0, 1.0)]),   # A2: 2+1+1=4
        ([0,1,4,5,8,9,10,11,12], [(1.0,1.0),(0.5,0.5)]), # A3: 5+1+0.5=6.5
        ([1,3],       [(0.5, 0.5), (1.5, 1.5)]),   # A4: 2+0.5+1.5=4
    ],
    # s3: Bùi Quang Minh - improving throughout
    's3': [
        ([3,4,6,8], []),                            # A1: 6/10
        ([1],       [(1.5, 1.5), (2.0, 2.0)]),     # A2: 3+1.5+2=6.5
        ([3,4,6,9], [(1.5, 1.5), (2.0, 2.0)]),     # A3: 10+1.5+2=13.5
        ([],        [(2.0, 2.0), (3.0, 3.0)]),     # A4: 4+2+3=9
    ],
    # s4: Cao Cường - slightly declining
    's4': [
        ([2,5], []),                                # A1: 8/10
        ([],    [(1.5, 1.5), (3.0, 3.0)]),         # A2: 4+1.5+3=8.5
        ([5,6,7,8,9], [(2.0, 2.0), (2.0, 2.0)]),  # A3: 9+2+2=13
        ([2],   [(1.0, 1.0), (2.5, 2.5)]),         # A4: 3+1+2.5=6.5
    ],
    # s5: Cao Đức Anh Quân - declining
    's5': [
        ([4,5,8], []),                              # A1: 7/10
        ([0],     [(1.5, 1.5), (2.0, 2.0)]),       # A2: 3+1.5+2=6.5
        ([3,5,7,8,10,11], [(1.5, 1.5), (1.0, 1.0)]), # A3: 8+1.5+1=10.5
        ([0,1,2], [(0.5, 0.5), (1.5, 1.5)]),       # A4: 1+0.5+1.5=3
    ],
    # s6: Cao Việt Hoàng - struggling, barely passes
    's6': [
        ([0,1,4,6,7,8], []),                        # A1: 4/10
        ([1,2,3],       [(1.0, 1.0), (1.0, 1.0)]), # A2: 1+1+1=3
        ([0,1,2,4,5,7,8,9,10,11,12], [(0.5,0.5),(0.5,0.5)]), # A3: 3+0.5+0.5=4
        None,                                       # A4: chưa nộp
    ],
    # s7: Đặng Bảo Anh - excellent, star student
    's7': [
        ([], []),                                   # A1: 10/10
        ([],  [(2.0, 2.0), (4.0, 4.0)]),           # A2: 4+2+4=10
        ([],  [(3.0, 3.0), (3.0, 3.0)]),           # A3: 14+3+3=20
        ([],  [(2.0, 2.0), (4.0, 4.0)]),           # A4: 4+2+4=10
    ],
    # s8: Đặng Huỳnh Quang - stable medium
    's8': [
        ([3,6,8], []),                              # A1: 7/10
        ([0],     [(1.5, 1.5), (2.5, 2.5)]),       # A2: 3+1.5+2.5=7
        ([2,4,6,8,10,11], [(1.5,1.5),(2.0,2.0)]),  # A3: 8+1.5+2=11.5
        ([3],     [(1.5, 1.5), (2.5, 2.5)]),       # A4: 3+1.5+2.5=7
    ],
    # s9: Đào Bình Phước - stable low-medium
    's9': [
        ([0,3,4,8], []),                            # A1: 6/10
        ([2,3],     [(1.0, 1.0), (2.0, 2.0)]),     # A2: 2+1+2=5
        ([1,3,5,7,9,10,12,13], [(1.0,1.0),(1.5,1.5)]), # A3: 6+1+1.5=8.5
        ([1,2],     [(1.0, 1.0), (2.0, 2.0)]),     # A4: 2+1+2=5
    ],
    # s10: Đào Duy Phúc - consistently good
    's10': [
        ([5,8], []),                                # A1: 8/10
        ([],    [(2.0, 2.0), (3.0, 3.0)]),         # A2: 4+2+3=9
        ([3,5,6], [(2.0, 2.0), (2.5, 2.5)]),       # A3: 11+2+2.5=15.5
        ([],    [(2.0, 2.0), (3.0, 3.0)]),         # A4: 4+2+3=9
    ],
    # s11: Đinh Hải Siêu - improving (weak start, better over time)
    's11': [
        ([1,3,6,7,8], []),                          # A1: 5/10
        ([2],         [(1.0, 1.0), (2.0, 2.0)]),   # A2: 3+1+2=6
        ([0,1,4,8,9], [(1.5, 1.5), (2.0, 2.0)]),  # A3: 9+1.5+2=12.5
        ([],          [(2.0, 2.0), (3.5, 3.5)]),   # A4: 4+2+3.5=9.5
    ],
    # s12: Đinh Lê Hoàng - poor throughout
    's12': [
        ([1,4,5,6,8,9], []),                        # A1: 4/10
        ([0,1,2,3],     [(0.5, 0.5), (0.5, 0.5)]), # A2: 0+0.5+0.5=1
        ([1,2,3,4,5,6,7,8,9,10,11,12,13], [(0.5,0.5),(0.5,0.5)]), # A3: 1+0.5+0.5=2
        None,                                       # A4: chưa nộp
    ],
    # s13: Đoàn Thanh Quang - stable good
    's13': [
        ([3,8], []),                                # A1: 8/10
        ([],    [(1.5, 1.5), (3.0, 3.0)]),         # A2: 4+1.5+3=8.5
        ([2,6,9,10,13], [(2.0, 2.0), (2.0, 2.0)]), # A3: 9+2+2=13
        ([],    [(1.5, 1.5), (3.0, 3.0)]),         # A4: 4+1.5+3=8.5
    ],
    # s14: Đồng Nguyên Hiếu - excellent, second best
    's14': [
        ([5], []),                                  # A1: 9/10
        ([],  [(2.0, 2.0), (3.5, 3.5)]),           # A2: 4+2+3.5=9.5
        ([8], [(2.5, 2.5), (3.0, 3.0)]),           # A3: 13+2.5+3=18.5
        ([],  [(2.0, 2.0), (3.5, 3.5)]),           # A4: 4+2+3.5=9.5
    ],
    # s15: Dương Công Quốc Anh - declining slowly
    's15': [
        ([1,4,7,8], []),                            # A1: 6/10
        ([1,3],     [(1.5, 1.5), (2.5, 2.5)]),     # A2: 2+1.5+2.5=6
        ([0,2,6,8,11,12,13], [(1.0,1.0),(1.5,1.5)]), # A3: 7+1+1.5=9.5
        None,                                       # A4: chưa nộp
    ],
}

# ─── Re-compute for anhhuy (s0) properly: ─────────────────────
# A2: wrong q2_mc idx 1 → 3MC + short 1.5 + essay AI=2.5, GV=3.0 → 3+1.5+3=7.5
SCORE_PROFILES['s0'][1] = ([1], [(1.5, 1.5), (2.5, 3.0)])
# A3: wrong 8 of 14 MC, essay1 AI=1.5, essay2 AI=1.5 GV=2.0 → 6+1.5+2=9.5...
# Let me fix: wrong 5 of 14 MC, essay AI=1.5+1.5=3 → 9+1.5+1.5=12?
# I want 11: wrong 6 MC → 8 correct, e1=1.5, e2=1.5 → 8+1.5+1.5=11 ✓
SCORE_PROFILES['s0'][2] = ([2,4,6,9,10,12], [(1.5, 1.5), (1.5, 1.5)])

# ─── Helpers ──────────────────────────────────────────────────
def get_mc_questions(adef):
    return [(i, q) for i, q in enumerate(adef['questions']) if q[0] == 'multiple_choice']

def get_essay_questions(adef):
    return [(i, q) for i, q in enumerate(adef['questions']) if q[0] in ('essay', 'short_answer')]

def wrong_choice(correct_id, choices):
    """Pick first wrong choice"""
    ids = [c[0] for c in choices]
    for cid in ids:
        if cid != correct_id:
            return cid
    return (correct_id + 1) % len(choices)

# ═══════════════════════════════════════════════════
# SQL GENERATION
# ═══════════════════════════════════════════════════

w("-- ============================================================")
w("-- SEED: Lớp K17A1 - Lập trình Python & Web")
w("-- Teacher: Phạm Thị Đào | Main student: Thái Anh Huy")
w("-- Generated: 2026-03-31")
w("-- ============================================================")
w("BEGIN;")
w("SET session_replication_role = replica;")
w("")

# ─── 1. CLASS ────────────────────────────────────────
w("-- ═══ 1. CLASS K17A1 ═══")
class_settings = {
    "defaults": {"lock_class": False},
    "enrollment": {"qr_code": {"is_active": False, "join_code": "K17A1-2026", "expires_at": None, "require_approval": False}, "manual_join_limit": None},
    "group_management": {"lock_groups": False, "allow_student_switch": False, "is_visible_to_students": True},
    "student_permissions": {"auto_lock_on_submission": False, "can_edit_profile_in_class": True}
}
w(f"INSERT INTO public.classes (id, school_id, teacher_id, name, subject, academic_year, description, class_settings, created_at)")
w(f"VALUES ('{CLASS_ID}', '{SCHOOL_ID}', '{TEACHER_ID}', 'K17A1', 'Lập trình Python & Web', '2025-2026',")
w(f"  'Lớp K17 nhóm A1 - Chuyên ngành Công nghệ Thông tin. Học phần Lập trình Python ứng dụng Web.',")
w(f"  '{json.dumps(class_settings, ensure_ascii=False)}', '2025-09-01T00:00:00+00:00') ON CONFLICT (id) DO NOTHING;")
w("")

# ─── 2. CLASS_TEACHERS ────────────────────────────────
ct_id = 'a0010001-0000-0000-0000-000000000001'
w("-- ═══ 2. CLASS_TEACHERS ═══")
w(f"INSERT INTO public.class_teachers (id, class_id, teacher_id, role)")
w(f"VALUES ('{ct_id}', '{CLASS_ID}', '{TEACHER_ID}', 'teacher') ON CONFLICT DO NOTHING;")
w("")

# ─── 3. CLASS_MEMBERS ─────────────────────────────────
w("-- ═══ 3. CLASS_MEMBERS (16 students) ═══")
for i, (sid, sname) in enumerate(STUDENTS):
    joined = ts(10 + i // 4)  # spread join dates
    w(f"INSERT INTO public.class_members (class_id, student_id, role, joined_at, status)")
    w(f"VALUES ('{CLASS_ID}', '{sid}', 'student', '{joined}', 'approved') ON CONFLICT DO NOTHING; -- {sname}")
w("")

# ─── 4. ASSIGNMENTS ───────────────────────────────────
w("-- ═══ 4. ASSIGNMENTS ═══")
for ai, adef in enumerate(ASSIGNMENTS_DEF):
    total_pts = adef['total_points']
    w(f"INSERT INTO public.assignments (id, class_id, teacher_id, title, description, is_published, published_at, total_points, created_at, updated_at)")
    w(f"VALUES ('{adef['id']}', '{CLASS_ID}', '{TEACHER_ID}',")
    w(f"  '{adef['title']}',")
    w(f"  '{adef['description']}',")
    pub_ts = ts(adef['available'] - 1)
    w(f"  true, '{pub_ts}', {total_pts},")
    w(f"  '{pub_ts}', '{pub_ts}') ON CONFLICT (id) DO NOTHING;")
w("")

# ─── 5. ASSIGNMENT_QUESTIONS ──────────────────────────
w("-- ═══ 5. ASSIGNMENT_QUESTIONS ═══")
for ai, adef in enumerate(ASSIGNMENTS_DEF):
    w(f"-- A{ai+1}: {adef['title']}")
    for qi, q in enumerate(adef['questions']):
        qtype, qtext, choices, correct_id, pts = q
        quid = q_id(ai+1, qi+1)
        if choices:
            choices_data = [{"id": c[0], "text": c[1], "isCorrect": c[0] == correct_id} for c in choices]
            content = {"override_text": qtext, "type": qtype, "choices": choices_data, "difficulty": 2 + (qi % 3)}
            answer_json = json.dumps({"correct_choice_ids": [correct_id], "general_explanation": f"Đáp án đúng là lựa chọn {correct_id}."}, ensure_ascii=False)
        else:
            content = {"override_text": qtext, "type": qtype, "difficulty": 3 + (qi % 2),
                       "ai_grading_keywords": [], "expected_answer": ""}
            answer_json = "null"
        content_json = json.dumps(content, ensure_ascii=False)
        w(f"INSERT INTO public.assignment_questions (id, assignment_id, question_id, custom_content, points, order_idx)")
        w(f"VALUES ('{quid}', '{adef['id']}', NULL, '{content_json}', {pts}, {qi+1}) ON CONFLICT DO NOTHING;")
    w("")

# ─── 6. ASSIGNMENT_DISTRIBUTIONS ─────────────────────
w("-- ═══ 6. ASSIGNMENT_DISTRIBUTIONS ═══")
for ai, adef in enumerate(ASSIGNMENTS_DEF):
    late_policy = {"policy_type": "daily_deduction", "deduction_value": 10, "unit": "percent", "max_days_allowed": 3, "lowest_possible_score": 0}
    settings = {"shuffle_choices": False, "shuffle_questions": False, "show_score_immediately": True,
                "student_review_mode": "full_review", "ai_feedback_enabled": True}
    avail_ts = ts(adef['available'])
    due_ts   = ts(adef['due'], hour=23, minute=59)
    status   = adef['status']
    w(f"INSERT INTO public.assignment_distributions (id, assignment_id, distribution_type, class_id, available_from, due_at, time_limit_minutes, allow_late, late_policy, status, settings, created_at)")
    w(f"VALUES ('{adef['dist_id']}', '{adef['id']}', 'class', '{CLASS_ID}',")
    w(f"  '{avail_ts}', '{due_ts}', {adef['time_limit']}, true,")
    w(f"  '{json.dumps(late_policy, ensure_ascii=False)}', '{status}',")
    w(f"  '{json.dumps(settings, ensure_ascii=False)}', '{avail_ts}') ON CONFLICT (id) DO NOTHING;")
w("")

# ─── 7. WORK_SESSIONS, SUBMISSIONS, SUBMISSION_ANSWERS ──
w("-- ═══ 7. WORK_SESSIONS + SUBMISSIONS + SUBMISSION_ANSWERS ═══")

grade_overrides = []  # collect for later
ai_evaluations  = []

for si, (sid, sname) in enumerate(STUDENTS):
    sk = f's{si}'
    profile = SCORE_PROFILES.get(sk)
    if not profile:
        continue

    for ai, adef in enumerate(ASSIGNMENTS_DEF):
        ap = profile[ai] if ai < len(profile) else None
        if ap is None:
            w(f"-- {sname} chưa nộp A{ai+1} (còn hạn)")
            continue

        mc_wrong, essay_scores = ap
        mc_questions  = get_mc_questions(adef)
        essay_questions = get_essay_questions(adef)

        # Compute scores
        mc_score = 0
        mc_answers = {}  # q_global_idx -> choice_id selected
        for mi, (gi, q) in enumerate(mc_questions):
            qtype, qtext, choices, correct_id, pts = q
            is_wrong = mi in mc_wrong
            selected = wrong_choice(correct_id, choices) if is_wrong else correct_id
            mc_answers[gi] = selected
            if not is_wrong:
                mc_score += pts

        essay_total_ai = 0
        essay_total_final = 0
        essay_answers = {}  # q_global_idx -> (ai_score, final_score, pts)
        for ei, (gi, q) in enumerate(essay_questions):
            qtype, qtext, _, _, pts = q
            if ei < len(essay_scores):
                ai_sc, final_sc = essay_scores[ei]
            else:
                ai_sc, final_sc = pts * 0.6, pts * 0.6
            essay_answers[gi] = (ai_sc, final_sc, pts)
            essay_total_ai    += ai_sc
            essay_total_final += final_sc

        total_final = round(mc_score + essay_total_final, 2)

        # Timing
        base_day = adef['available']
        due_day  = adef['due']
        is_anhhuy = (sid == ANHHUY_ID)
        is_late = False

        if is_anhhuy and ai == 2:  # A3 late for anhhuy
            submit_day = due_day + 1
            is_late = True
        else:
            submit_day = base_day + (si % 2)  # vary submission timing

        start_ts  = ts(base_day + (si % 3), hour=7 + (si % 3))
        submit_ts = ts(submit_day, hour=9 + (si % 4), minute=(si * 7) % 60)

        wsid  = ws_id(si, ai+1)
        sbid  = sub_id(si, ai+1)
        is_graded = adef['status'] == 'closed'

        # work_session
        w(f"-- {sname} - A{ai+1} | score={total_final}")
        w(f"INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)")
        w(f"VALUES ('{wsid}', '{adef['dist_id']}', '{adef['id']}', '{sid}',")
        w(f"  '{start_ts}', '{submit_ts}', 1, 'submitted', {300 + si * 120 + ai * 60},")
        w(f"  '{start_ts}', '{submit_ts}') ON CONFLICT DO NOTHING;")

        # submission
        w(f"INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, is_voided, created_at, updated_at)")
        w(f"VALUES ('{sbid}', '{adef['id']}', '{adef['dist_id']}', '{sid}', '{wsid}',")
        w(f"  '{start_ts}', '{submit_ts}', {str(is_late).lower()}, {total_final}, {str(is_graded).lower()}, false,")
        w(f"  '{start_ts}', '{submit_ts}') ON CONFLICT DO NOTHING;")

        # submission_answers
        for qi, q in enumerate(adef['questions']):
            qtype, qtext, choices, correct_id, pts = q
            said = sa_id(si, ai+1, qi+1)
            quid = q_id(ai+1, qi+1)

            if choices is not None:  # MC
                selected = mc_answers[qi]
                is_correct = (selected == correct_id)
                sc = pts if is_correct else 0
                answer = json.dumps({"selected_choice_ids": [selected]}, ensure_ascii=False)
                ai_conf = 1.0 if is_correct else 0.0
                ai_fb = json.dumps({"comment": "Câu trả lời trắc nghiệm" + (" đúng." if is_correct else " sai.")}, ensure_ascii=False)
                w(f"INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at, created_at, updated_at)")
                w(f"VALUES ('{said}', '{wsid}', '{quid}', '{answer}',")
                w(f"  {sc}, {ai_conf}, {sc},")
                w(f"  '{ai_fb}',")
                w(f"  '{submit_ts}', '{submit_ts}', '{submit_ts}') ON CONFLICT DO NOTHING;")
            else:  # essay/short_answer
                ei_local = [i for i, (gi, _) in enumerate(essay_questions) if gi == qi]
                if ei_local:
                    ei = ei_local[0]
                else:
                    ei = 0
                ai_sc, final_sc, max_pts = essay_answers.get(qi, (pts * 0.6, pts * 0.6, pts))

                if qtype == 'short_answer':
                    sample_answers = {
                        (1, 4): "def sum_n(n):\n    return sum(range(1, n+1))",
                        (3, 4): "@app.route('/hello')\ndef hello():\n    return 'Xin chào, Flask!'",
                    }
                    ans_text = sample_answers.get((ai+1, qi+1), f"Câu trả lời của {sname} cho câu {qi+1}")
                    answer = json.dumps({"text": ans_text}, ensure_ascii=False)
                else:
                    essay_samples = {
                        (1, 5): None,  # A1 has no essay
                        (2, 5): f"def fibonacci(n):\n    if n <= 0:\n        return []\n    a, b = 0, 1\n    result = []\n    for _ in range(n):\n        result.append(a)\n        a, b = b, a+b\n    return result\n\nn = int(input())\nprint(fibonacci(n))",
                        (3, 14): "class BankAccount:\n    def __init__(self, account_no, owner, balance=0):\n        self.__account_no = account_no\n        self.__owner = owner\n        self.__balance = balance\n\n    def deposit(self, amount):\n        if amount > 0:\n            self.__balance += amount\n\n    def withdraw(self, amount):\n        if 0 < amount <= self.__balance:\n            self.__balance -= amount\n            return True\n        return False\n\n    def __str__(self):\n        return f'Tài khoản {self.__account_no} - {self.__owner}: {self.__balance} VND'",
                        (3, 15): "@classmethod là method thuộc về class, nhận cls; @staticmethod không nhận tham số đặc biệt.",
                        (4, 5): "@app.route('/hello')\ndef hello():\n    return 'Xin chào, Flask!'",
                    }
                    ans_text = essay_samples.get((ai+1, qi+1), f"Bài làm tự luận của {sname}. Đây là nội dung câu trả lời cho câu {qi+1} của bài {ai+1}.")
                    answer = json.dumps({"text": ans_text}, ensure_ascii=False)

                ai_conf = round(min(ai_sc / max_pts, 1.0), 2) if max_pts > 0 else 0.0
                strengths = ["Hiểu đúng yêu cầu bài"] if ai_sc >= max_pts * 0.6 else []
                weaknesses = ["Cần bổ sung giải thích"] if ai_sc < max_pts else []
                ai_fb = json.dumps({
                    "comment": f"AI chấm: {ai_sc}/{max_pts} điểm.",
                    "strengths": strengths,
                    "weaknesses": weaknesses,
                    "suggestions": ["Xem lại lý thuyết"] if ai_sc < max_pts * 0.7 else []
                }, ensure_ascii=False)

                graded_by_col = "NULL"
                teacher_fb_col = "NULL"

                # Grade override for anhhuy A2 essay (ai=1, qi=5)
                is_overridden = (is_anhhuy and ai == 1 and qi == 5)
                if is_overridden:
                    teacher_fb_col = "'" + json.dumps({"comment": "Ý tưởng đúng nhưng chưa xử lý edge case. Cộng thêm 0.5 điểm.", "rating": 4}, ensure_ascii=False).replace("'", "''") + "'"
                    graded_by_col = f"'{TEACHER_ID}'"
                    grade_overrides.append((said, ai_sc, final_sc, TEACHER_ID, submit_ts))

                w(f"INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, ai_score, ai_confidence, final_score, ai_feedback, teacher_feedback, graded_by, graded_at, created_at, updated_at)")
                w(f"VALUES ('{said}', '{wsid}', '{quid}', '{answer.replace(chr(39), chr(39)*2)}',")
                w(f"  {ai_sc}, {ai_conf}, {final_sc},")
                w(f"  '{ai_fb.replace(chr(39), chr(39)*2)}',")
                w(f"  {teacher_fb_col}, {graded_by_col},")
                w(f"  '{submit_ts}', '{submit_ts}', '{submit_ts}') ON CONFLICT DO NOTHING;")

                # AI evaluation record for essay
                ev = ev_id(si, ai+1, qi+1)
                rationale = json.dumps({
                    "criteria_scores": [{"criteria_id": "crit-1", "score": round(ai_sc, 2), "comment": f"Điểm AI: {ai_sc}/{max_pts}"}],
                    "overall_comment": f"Bài làm đạt {round(ai_sc/max_pts*100)}% yêu cầu."
                }, ensure_ascii=False)
                ai_evaluations.append(f"INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)\n"
                    f"VALUES ('{ev}', '{said}', 'gemini-pro', '1.5', {ai_sc}, {ai_conf},\n"
                    f"  'AI đánh giá câu tự luận.', '{rationale.replace(chr(39), chr(39)*2)}',\n"
                    f"  '{submit_ts}') ON CONFLICT DO NOTHING;")
        w("")

# ─── 8. GRADE_OVERRIDES ───────────────────────────────
w("-- ═══ 8. GRADE_OVERRIDES ═══")
for i, (said, old_sc, new_sc, gv_id, gv_ts) in enumerate(grade_overrides):
    go_id = f'00000000-0000-0000-0003-ee{i+1:010d}'
    w(f"INSERT INTO public.grade_overrides (id, submission_answer_id, overridden_by, old_score, new_score, reason, created_at)")
    w(f"VALUES ('{go_id}', '{said}', '{gv_id}', {old_sc}, {new_sc},")
    w(f"  'Học sinh trình bày ý đúng nhưng code chưa hoàn chỉnh. Cộng 0.5 điểm khuyến khích.', '{gv_ts}') ON CONFLICT DO NOTHING;")
w("")

# ─── 9. AI_EVALUATIONS ────────────────────────────────
w("-- ═══ 9. AI_EVALUATIONS ═══")
for ev_sql in ai_evaluations:
    w(ev_sql)
w("")

# ─── 10. SUBMISSION_ANALYTICS ─────────────────────────
w("-- ═══ 10. SUBMISSION_ANALYTICS (anhhuy) ═══")
for ai, adef in enumerate(ASSIGNMENTS_DEF):
    if SCORE_PROFILES['s0'][ai] is None:
        continue
    sbid = sub_id(0, ai+1)
    sa_id_val = f'00000000-0000-0000-0002-ff00{ai+1:08d}'
    metrics = json.dumps({
        "time_per_question": {f"q{q+1}": 30 + q * 15 for q in range(len(adef['questions']))},
        "accuracy_by_tag": {"python": 0.7 + ai * 0.05, "oop": 0.6 + ai * 0.08},
        "difficulty_vs_score": [{"difficulty": 2, "score": 0.9}, {"difficulty": 3, "score": 0.75}, {"difficulty": 4, "score": 0.6}]
    }, ensure_ascii=False)
    w(f"INSERT INTO public.submission_analytics (id, submission_id, metrics, created_at)")
    w(f"VALUES ('{sa_id_val}', '{sbid}', '{metrics}', '{ts(adef['due'])}') ON CONFLICT DO NOTHING;")
w("")

# ─── 11. AI_RECOMMENDATIONS ───────────────────────────
w("-- ═══ 11. AI_RECOMMENDATIONS (cho GV Phạm Thị Đào về lớp K17A1) ═══")
recs = [
    ('a1000001-0000-0000-0000-000000000001', ANHHUY_ID, 'individual', 4,
     'Thái Anh Huy: Cần ôn lại Python list reference và mutation',
     'Học sinh liên tục sai câu về list mutation (y=x vs y=x.copy()). Khuyến nghị ôn lại bài "Biến và tham chiếu trong Python".',
     {'exercises': [ASSIGN_IDS[0]], 'documents': ['https://docs.python.org/3/library/copy.html']}),
    ('a1000002-0000-0000-0000-000000000002', 'c8778c6b-7099-5c09-916c-6b0dabafde41', 'individual', 2,
     'Đặng Bảo Anh: Học sinh xuất sắc - nên giao bài nâng cao',
     'Học sinh đạt điểm tuyệt đối các bài kiểm tra. Đề xuất giao thêm bài tập nâng cao về Design Patterns và Web API.',
     {'exercises': [], 'documents': []}),
    ('a1000003-0000-0000-0000-000000000003', None, 'class', 3,
     'Lớp K17A1: Kiến thức OOP còn yếu - cần ôn tập trước khi cuối kỳ',
     'Điểm trung bình giữa kỳ OOP là 11.5/20. Khuyến nghị tổ chức 1 buổi ôn tập về class, inheritance trước kỳ thi.',
     {'exercises': [ASSIGN_IDS[2]], 'documents': []}),
    ('a1000004-0000-0000-0000-000000000004', '1b091e49-228a-5e43-99ed-47ce336fbdb8', 'individual', 5,
     'Đinh Lê Hoàng: Nguy cơ không qua môn - cần can thiệp ngay',
     'Điểm các bài kiểm tra đều dưới 5/10. Khuyến nghị gặp gỡ học sinh để tìm hiểu nguyên nhân và có kế hoạch hỗ trợ.',
     {'exercises': [], 'documents': []}),
]
for rec_id, student_id, rtype, priority, title, desc, resources in recs:
    sid_col = f"'{student_id}'" if student_id else 'NULL'
    resources_json = json.dumps(resources, ensure_ascii=False)
    w(f"INSERT INTO public.ai_recommendations (id, teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at)")
    w(f"VALUES ('{rec_id}', '{TEACHER_ID}', '{CLASS_ID}', {sid_col}, '{rtype}', {priority},")
    w(f"  '{title}',")
    w(f"  '{desc}',")
    w(f"  '{resources_json}', false, '{ts(70)}') ON CONFLICT DO NOTHING;")
w("")

# ─── 12. TEACHER_NOTES ────────────────────────────────
w("-- ═══ 12. TEACHER_NOTES ═══")
notes = [
    ('b1000001-0000-0000-0000-000000000001', ANHHUY_ID,
     'Em Huy nắm vững cú pháp Python nhưng còn lúng túng với khái niệm tham chiếu biến. Cần chú ý câu hỏi liên quan đến mutable objects. Có tiến bộ rõ ở bài Flask.', True),
    ('b1000002-0000-0000-0000-000000000002', 'c8778c6b-7099-5c09-916c-6b0dabafde41',
     'Đặng Bảo Anh - học sinh tiêu biểu. Làm bài rất chắc chắn, code sạch sẽ, giải thích rõ ràng. Nên đề xuất tham gia cuộc thi lập trình.', True),
    ('b1000003-0000-0000-0000-000000000003', '1b091e49-228a-5e43-99ed-47ce336fbdb8',
     'Đinh Lê Hoàng - đã gặp riêng. Nói rằng đang gặp khó khăn gia đình. Cần quan tâm hỗ trợ thêm.', True),
]
for nt_id, student_id, content, is_private in notes:
    w(f"INSERT INTO public.teacher_notes (id, teacher_id, student_id, content, is_private, created_at)")
    w(f"VALUES ('{nt_id}', '{TEACHER_ID}', '{student_id}',")
    w(f"  '{content}', {str(is_private).lower()}, '{ts(72)}') ON CONFLICT DO NOTHING;")
w("")

w("SET session_replication_role = DEFAULT;")
w("COMMIT;")

output = '\n'.join(lines)
with open('seed_data/k17a1_seed.sql', 'w', encoding='utf-8') as f:
    f.write(output)

print(f"Generated {len(lines)} lines")
print(f"Grade overrides: {len(grade_overrides)}")
print(f"AI evaluations: {len(ai_evaluations)}")
