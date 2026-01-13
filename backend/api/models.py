from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator

# ============================================================================
# USER MODEL - Handles authentication for all three roles
# ============================================================================
class User(AbstractUser):
    """
    Custom User model that extends Django's built-in user.
    This is what Flutter's auth_service.dart communicates with for login/register.
    
    Flutter Connection:
    - LoginScreen sends email/password → /api/auth/login/
    - RegisterScreen sends student data → /api/auth/register/
    """
    
    # Role choices - these match the roles in Flutter's constants/roles.dart
    ADMIN = 'ADMIN'
    TEACHER = 'TEACHER'
    STUDENT = 'STUDENT'
    
    ROLE_CHOICES = [
        (ADMIN, 'Admin'),
        (TEACHER, 'Teacher'),
        (STUDENT, 'Student'),
    ]
    
    # Additional fields beyond Django's default User
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default=STUDENT)
    
    # Student-specific fields
    student_id = models.CharField(max_length=20, unique=True, null=True, blank=True)
    program = models.CharField(max_length=100, null=True, blank=True)  # e.g., "Computer Science"
    semester = models.IntegerField(default=1, validators=[MinValueValidator(1), MaxValueValidator(10)])
    birth_date = models.DateField(null=True, blank=True)
    phone = models.CharField(max_length=15, blank=True)
    address = models.TextField(blank=True)
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
    
    # Registration approval system
    is_approved = models.BooleanField(default=False)
    rejection_reason = models.TextField(null=True, blank=True)  # Explain why a registration was rejected
    
    # Foreign key to Group (student belongs to one group)
    group = models.ForeignKey('Group', on_delete=models.SET_NULL, null=True, blank=True, related_name='students')
    
    class Meta:
        ordering = ['username']
    
    def __str__(self):
        return f"{self.username} ({self.role})"


# ============================================================================
# COURSE MODEL - Represents academic courses
# ============================================================================
class Course(models.Model):
    """
    Represents a course (e.g., "Mobile Development", "Algorithms").
    
    Flutter Connection:
    - Admin assigns courses via ManageCoursesScreen → POST /api/courses/
    - Teachers see their courses in MyCoursesScreen → GET /api/courses/my-courses/
    - Students see their courses in MyCoursesScreen → GET /api/courses/student-courses/
    """
    
    code = models.CharField(max_length=10, unique=True)  # e.g., "DAM301"
    name = models.CharField(max_length=200)  # e.g., "Mobile Development"
    description = models.TextField(blank=True)
    credits = models.IntegerField(default=3)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['code']
    
    def __str__(self):
        return f"{self.code} - {self.name}"


# ============================================================================
# GROUP MODEL - Student groups/classes
# ============================================================================
class Group(models.Model):
    """
    Represents a student group (e.g., "IFA G1", "IFA G2").
    
    Flutter Connection:
    - Admin creates groups via AdminHomeScreen
    - Admin assigns students to groups
    - Admin assigns courses to groups
    """
    
    name = models.CharField(max_length=50, unique=True)  # e.g., "IFA G1"
    academic_year = models.CharField(max_length=10)  # e.g., "2024-2025"
    
    # Many-to-many: a group has multiple courses, a course can be for multiple groups
    courses = models.ManyToManyField(Course, related_name='groups', blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['name']
    
    def __str__(self):
        return self.name

# ============================================================================
# ASSIGNMENT MODEL - Junction between Teacher, Course, and Group
# ============================================================================
class CourseAssignment(models.Model):
    """
    Solves the logical problem of assigning specific teachers to specific courses for specific groups.
    A teacher can teach 'Math' to 'Group A', but a different teacher can teach 'Math' to 'Group B'.
    """
    teacher = models.ForeignKey(User, on_delete=models.CASCADE, limit_choices_to={'role': User.TEACHER}, related_name='teaching_assignments')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='assignments')
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='course_assignments')
    academic_year = models.CharField(max_length=10) # Overrides group's year if needed

    class Meta:
        unique_together = ['course', 'group', 'academic_year'] # Only one teacher per course/group combo

    def __str__(self):
        return f"{self.teacher.username} - {self.course.code} ({self.group.name})"


# ============================================================================
# GRADE MODEL - Student marks/grades
# ============================================================================
class Grade(models.Model):
    """
    Stores student grades for each course.
    
    Flutter Connection:
    - Teachers enter marks via StudentListScreen → POST/PUT /api/grades/
    - Students view marks via MarksScreen → GET /api/grades/my-grades/
    """
    
    student = models.ForeignKey(
        User, 
        on_delete=models.CASCADE,
        limit_choices_to={'role': User.STUDENT},
        related_name='grades'
    )
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='grades')
    
    # Grade components
    td_mark = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        null=True, 
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(20)]
    )
    tp_mark = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        null=True, 
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(20)]
    )
    exam_mark = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        null=True, 
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(20)]
    )
    
    # Comments from teacher
    comments = models.TextField(blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        # Each student can have only one grade record per course
        unique_together = ['student', 'course']
        ordering = ['-updated_at']
    
    def __str__(self):
        return f"{self.student.username} - {self.course.code}"
    
    @property
    def average(self):
        """Calculate average grade"""
        marks = [m for m in [self.td_mark, self.tp_mark, self.exam_mark] if m is not None]
        return sum(marks) / len(marks) if marks else None


# ============================================================================
# ATTENDANCE MODEL - Track student attendance
# ============================================================================
class Attendance(models.Model):
    """
    Records student attendance for each course session.
    
    Flutter Connection:
    - Teachers mark attendance via MarkAttendanceScreen → POST /api/attendance/
    """
    
    student = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        limit_choices_to={'role': User.STUDENT},
        related_name='attendances'
    )
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='attendances')
    
    date = models.DateField()
    week_number = models.IntegerField()  # Week 1, 2, 3, etc.
    
    # Attendance status
    PRESENT = 'PRESENT'
    ABSENT = 'ABSENT'
    LATE = 'LATE'
    EXCUSED = 'EXCUSED'
    
    STATUS_CHOICES = [
        (PRESENT, 'Present'),
        (ABSENT, 'Absent'),
        (LATE, 'Late'),
        (EXCUSED, 'Excused'),
    ]
    
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=PRESENT)
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-date']
    
    def __str__(self):
        return f"{self.student.username} - {self.course.code} - {self.date}"


# ============================================================================
# FILE MODEL - Course materials and documents
# ============================================================================
class CourseFile(models.Model):
    """
    Stores uploaded files (PDFs, images, etc.) for courses.
    
    Flutter Connection:
    - Teachers upload files via UploadCourseFilesScreen → POST /api/files/
    - Students view/download via CourseFilesScreen → GET /api/files/course/{id}/
    """
    
    FILE_TYPES = [
        ('LECTURE', 'Lecture Notes'),
        ('LAB', 'Lab Material'),
        ('ASSIGNMENT', 'Assignment'),
        ('SOLUTION', 'Solution'),
        ('OTHER', 'Other'),
    ]
    
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='files')
    uploaded_by = models.ForeignKey(User, on_delete=models.CASCADE)
    
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    file = models.FileField(upload_to='course_files/')
    file_type = models.CharField(max_length=20, choices=FILE_TYPES, default='OTHER')
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.course.code} - {self.title}"


# ============================================================================
# TIMETABLE MODEL - Class schedules
# ============================================================================
class Timetable(models.Model):
    """
    Stores timetable/schedule images for each group.
    
    Flutter Connection:
    - Admin uploads via UploadTimetableScreen → POST /api/timetables/
    - Students view via TimetableScreen → GET /api/timetables/my-timetable/
    """
    
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='timetables')
    
    title = models.CharField(max_length=200)  # e.g., "Spring 2025 Schedule"
    image = models.ImageField(upload_to='timetables/')
    
    # Optional: semester info
    semester = models.CharField(max_length=50, blank=True)
    academic_year = models.CharField(max_length=10)
    
    is_active = models.BooleanField(default=True)  # Only show active timetables
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.group.name} - {self.title}"


# ============================================================================
# MESSAGE MODEL - Peer-to-peer communication
# ============================================================================
class Message(models.Model):
    """
    Handles peer-to-peer messaging between actors.
    
    Flutter Connection: ChatScreen uses this for communication.
    """
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f"From {self.sender.username} to {self.receiver.username}"


# ============================================================================
# NOTIFICATION MODEL - System alerts and exam notifications
# ============================================================================
class Notification(models.Model):
    """
    Targeted notifications for users (e.g., Exam alerts, registration approval).
    """
    NOTIFICATION_TYPES = [
        ('EXAM', 'Exam Notification'),
        ('GRADE', 'New Grade Published'),
        ('INFO', 'General Information'),
        ('REG', 'Registration Update'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=200)
    message = models.TextField()
    notification_type = models.CharField(max_length=10, choices=NOTIFICATION_TYPES, default='INFO')
    created_at = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.notification_type}: {self.title} for {self.user.username}"

# ============================================================================
# SCHEDULE MODEL - Specific class times/rooms
# ============================================================================
class ScheduleSession(models.Model):
    """
    Represents a specific time slot for a CourseAssignment.
    """
    assignment = models.ForeignKey(CourseAssignment, on_delete=models.CASCADE, related_name='sessions')
    
    DAY_CHOICES = [
        ('MONDAY', 'Monday'),
        ('TUESDAY', 'Tuesday'),
        ('WEDNESDAY', 'Wednesday'),
        ('THURSDAY', 'Thursday'),
        ('FRIDAY', 'Friday'),
        ('SATURDAY', 'Saturday'),
        ('SUNDAY', 'Sunday'),
    ]
    
    day = models.CharField(max_length=10, choices=DAY_CHOICES)
    start_time = models.TimeField()
    end_time = models.TimeField()
    room = models.CharField(max_length=50)
    
    SESSION_TYPES = [
        ('LECTURE', 'Lecture'),
        ('LAB', 'Lab'),
        ('TUTORIAL', 'Tutorial'),
    ]
    session_type = models.CharField(max_length=20, choices=SESSION_TYPES, default='LECTURE')
    
    class Meta:
        ordering = ['day', 'start_time']

    def __str__(self):
        return f"{self.assignment.course.code} - {self.day} {self.start_time}"
