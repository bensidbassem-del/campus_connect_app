import random
from datetime import date, timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from api.models import Course, Group, CourseAssignment, Grade, Attendance, CourseFile, Timetable, Message, Notification

User = get_user_model()

class Command(BaseCommand):
    help = 'Populate the database with sample data'

    def handle(self, *args, **kwargs):
        self.stdout.write('Populating database...')

        # 1. Create Groups
        groups = []
        for name in ['IFA G1', 'IFA G2', 'IFA G3']:
            group, created = Group.objects.get_or_create(
                name=name,
                defaults={'academic_year': '2025-2026'}
            )
            groups.append(group)
            if created:
                self.stdout.write(f'Created group: {name}')

        # 2. Create Courses
        courses_data = [
            ('DAM301', 'Mobile Development', 4),
            ('DAM302', 'Advanced Algorithms', 3),
            ('DAM303', 'Database Management', 3),
            ('DAM304', 'Cloud Computing', 4),
            ('DAM305', 'Ethical Hacking', 3),
        ]
        courses = []
        for code, name, credits in courses_data:
            course, created = Course.objects.get_or_create(
                code=code,
                defaults={'name': name, 'credits': credits}
            )
            courses.append(course)
            if created:
                self.stdout.write(f'Created course: {name}')

        # 3. Create Admin
        admin, created = User.objects.get_or_create(
            username='admin',
            defaults={
                'email': 'admin@campusconnect.com',
                'role': User.ADMIN,
                'is_staff': True,
                'is_superuser': True,
                'is_approved': True
            }
        )
        if created:
            admin.set_password('admin123')
            admin.save()
            self.stdout.write('Created admin user: admin')

        # 4. Create Teachers
        teachers = []
        teacher_names = [('teacher1', 'John', 'Doe'), ('teacher2', 'Jane', 'Smith')]
        for username, first, last in teacher_names:
            teacher, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'first_name': first,
                    'last_name': last,
                    'email': f'{username}@campusconnect.com',
                    'role': User.TEACHER,
                    'is_approved': True
                }
            )
            if created:
                teacher.set_password('teacher123')
                teacher.save()
                self.stdout.write(f'Created teacher user: {username}')
            teachers.append(teacher)

        # 5. Create Students
        student_data = [
            ('student1', 'Alice', 'Johnson', 'IFA G1', True),
            ('student2', 'Bob', 'Brown', 'IFA G1', True),
            ('student3', 'Charlie', 'Davis', 'IFA G2', True),
            ('student4', 'Diana', 'Evans', 'IFA G2', False), # Pending
            ('student5', 'Eve', 'Foster', 'IFA G3', True),
        ]
        students = []
        for username, first, last, group_name, approved in student_data:
            group = Group.objects.get(name=group_name)
            student, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'first_name': first,
                    'last_name': last,
                    'email': f'{username}@campusconnect.com',
                    'role': User.STUDENT,
                    'student_id': f'STU{random.randint(1000, 9999)}',
                    'group': group,
                    'is_approved': approved,
                    'program': 'Computer Science',
                }
            )
            if created:
                student.set_password('student123')
                student.save()
                self.stdout.write(f'Created student user: {username}')
            students.append(student)

        # 6. Course Assignments
        for i, course in enumerate(courses):
            # Assign first 3 courses to teacher 1, rest to teacher 2
            teacher = teachers[0] if i < 3 else teachers[1]
            # Assign course to at least one group
            group = groups[i % len(groups)]
            CourseAssignment.objects.get_or_create(
                course=course,
                group=group,
                academic_year='2025-2026',
                defaults={'teacher': teacher}
            )
            group.courses.add(course)

        # 7. Grades
        for student in [s for s in students if s.is_approved]:
            if student.group:
                for course in student.group.courses.all():
                    Grade.objects.get_or_create(
                        student=student,
                        course=course,
                        defaults={
                            'td_mark': random.uniform(10, 18),
                            'tp_mark': random.uniform(12, 19),
                            'exam_mark': random.uniform(8, 16),
                        }
                    )

        # 8. Attendance
        today = date.today()
        for student in [s for s in students if s.is_approved]:
            if student.group:
                for course in student.group.courses.all():
                    for week in range(1, 5):
                        Attendance.objects.get_or_create(
                            student=student,
                            course=course,
                            week_number=week,
                            date=today - timedelta(weeks=4-week),
                            defaults={'status': random.choice(['PRESENT', 'PRESENT', 'PRESENT', 'ABSENT', 'LATE'])}
                        )

        # 9. Announcements/Notifications
        for student in students:
            Notification.objects.create(
                user=student,
                title='Welcome to Campus Connect',
                message='Welcome to the new academic year! Explore your schedules and courses.',
                notification_type='INFO'
            )

        self.stdout.write(self.style.SUCCESS('Successfully populated database!'))
