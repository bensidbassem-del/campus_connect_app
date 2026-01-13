"""
Campus Connect - Serializers
Serializers convert Django model instances to JSON (for Flutter) and vice versa.
Think of them as translators between Python objects and JSON data.

When Flutter sends JSON → Serializer validates and creates Python objects
When Django sends data → Serializer converts Python objects to JSON for Flutter
"""

from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User, Course, Group, Grade, Attendance, CourseFile, Timetable, CourseAssignment, Message, Notification, ScheduleSession


# ============================================================================
# USER SERIALIZERS - For authentication and user management
# ============================================================================

class UserSerializer(serializers.ModelSerializer):
    """
    Main user serializer - converts User model to/from JSON.
    
    Flutter receives this format after login or when fetching user profile.
    Example JSON Flutter gets:
    {
        "id": 1,
        "username": "student123",
        "email": "student@example.com",
        "role": "STUDENT",
        "first_name": "John",
        "last_name": "Doe",
        "student_id": "192031234",
        ...
    }
    """
    
    # Include group details when serializing
    group_name = serializers.SerializerMethodField()
    group_id = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'role', 'student_id', 'program', 'semester', 'birth_date', 
            'phone', 'address', 'profile_picture', 'is_approved', 
            'rejection_reason', 'group', 'group_name', 'group_id'
        ]
        read_only_fields = ['id', 'role']

    def get_group_name(self, obj):
        return obj.group.name if obj.group else None

    def get_group_id(self, obj):
        return obj.group.id if obj.group else None


class RegisterSerializer(serializers.ModelSerializer):
    """
    Used when student registers via Flutter's RegisterScreen.
    
    Flutter sends:
    {
        "username": "newstudent",
        "password": "securepass123",
        "email": "new@example.com",
        "first_name": "Jane",
        "last_name": "Smith",
        "student_id": "192031235",
        ...
    }
    """
    
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, label="Confirm Password")
    
    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'password2',
            'first_name', 'last_name', 'student_id',
            'birth_date', 'phone', 'address', 'role'
        ]
    
    def validate(self, data):
        """Ensure passwords match"""
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords don't match"})
        return data
    
    def create(self, validated_data):
        """
        Create new user with hashed password.
        is_approved defaults to False - admin must approve before login works.
        IMPORTANT: Public registration is ONLY for Students.
        """
        validated_data.pop('password2')  # Remove password2, not needed in model
        
        # Security: Always force STUDENT role for public registration
        # Even if a malicious request sends role='ADMIN' or 'TEACHER'
        validated_data.pop('role', None) 
        
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            student_id=validated_data.get('student_id'),
            birth_date=validated_data.get('birth_date'),
            phone=validated_data.get('phone', ''),
            address=validated_data.get('address', ''),
            role=User.STUDENT, # Hardcoded for safety
            is_approved=False  # Must be approved by admin
        )
        return user


class LoginSerializer(serializers.Serializer):
    """
    Handles login validation when Flutter sends credentials.
    
    Flutter LoginScreen sends:
    {
        "username": "student123",
        "password": "password123"
    }
    """
    
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        """
        Authenticate user and check if approved.
        This runs when Flutter POST to /api/auth/login/
        """
        username = data.get('username')
        password = data.get('password')
        
        # Authenticate credentials
        user = authenticate(username=username, password=password)
        
        if not user:
            raise serializers.ValidationError("Invalid credentials")
        
        # Check if student is approved
        if user.role == User.STUDENT and not user.is_approved:
            raise serializers.ValidationError("Account pending approval")
        
        data['user'] = user
        return data


# ============================================================================
# COURSE SERIALIZERS
# ============================================================================

class CourseSerializer(serializers.ModelSerializer):
    """
    Course data for Flutter.
    """
    
    class Meta:
        model = Course
        fields = ['id', 'code', 'name', 'description', 'credits']


class CourseCreateSerializer(serializers.ModelSerializer):
    """
    Used when admin creates courses.
    """
    
    class Meta:
        model = Course
        fields = ['code', 'name', 'description', 'credits']


class ScheduleSessionSerializer(serializers.ModelSerializer):
    """Specific time slot for a course"""
    assignment_id = serializers.PrimaryKeyRelatedField(
        queryset=CourseAssignment.objects.all(), source='assignment', write_only=True
    )
    course_code = serializers.SerializerMethodField()
    course_name = serializers.SerializerMethodField()
    group_name = serializers.SerializerMethodField()
    teacher_name = serializers.SerializerMethodField()
    
    class Meta:
        model = ScheduleSession
        fields = [
            'id', 'assignment_id', 'course_code', 'course_name', 
            'group_name', 'teacher_name', 'day', 'start_time', 
            'end_time', 'room', 'session_type'
        ]

    def get_course_code(self, obj):
        return obj.assignment.course.code if obj.assignment and obj.assignment.course else None

    def get_course_name(self, obj):
        return obj.assignment.course.name if obj.assignment and obj.assignment.course else None

    def get_group_name(self, obj):
        return obj.assignment.group.name if obj.assignment and obj.assignment.group else None

    def get_teacher_name(self, obj):
        return obj.assignment.teacher.get_full_name() if obj.assignment and obj.assignment.teacher else None

class CourseAssignmentSerializer(serializers.ModelSerializer):
    """
    The 'glue' that tells Flutter which teacher is teaching what to whom.
    """
    teacher_name = serializers.CharField(source='teacher.get_full_name', read_only=True)
    course_name = serializers.CharField(source='course.name', read_only=True)
    course_code = serializers.CharField(source='course.code', read_only=True)
    group_name = serializers.CharField(source='group.name', read_only=True)
    group_id = serializers.PrimaryKeyRelatedField(source='group', read_only=True)
    sessions = ScheduleSessionSerializer(many=True, read_only=True)

    class Meta:
        model = CourseAssignment
        fields = [
            'id', 'teacher', 'teacher_name',
            'course', 'course_name', 'course_code',
            'group', 'group_id', 'group_name', 'academic_year', 'sessions'
        ]


# ============================================================================
# GROUP SERIALIZERS
# ============================================================================

class GroupSerializer(serializers.ModelSerializer):
    """
    Group information with student count.
    
    Flutter admin panel shows:
    {
        "id": 1,
        "name": "IFA G1",
        "academic_year": "2024-2025",
        "student_count": 35,
        "courses": [...]
    }
    """
    
    student_count = serializers.SerializerMethodField()
    courses = CourseSerializer(many=True, read_only=True)
    
    class Meta:
        model = Group
        fields = ['id', 'name', 'academic_year', 'student_count', 'courses']
    
    def get_student_count(self, obj):
        """Count students in this group"""
        return obj.students.count()


# ============================================================================
# GRADE SERIALIZERS
# ============================================================================

class GradeSerializer(serializers.ModelSerializer):
    """
    Grade data for students and teachers.
    
    Flutter MarksScreen receives:
    [
        {
            "id": 1,
            "course_code": "DAM301",
            "course_name": "Mobile Development",
            "td_mark": 15.5,
            "tp_mark": 16.0,
            "exam_mark": 14.0,
            "average": 15.17,
            "comments": "Good progress"
        },
        ...
    ]
    """
    
    course_code = serializers.CharField(source='course.code', read_only=True)
    course_name = serializers.CharField(source='course.name', read_only=True)
    student_name = serializers.CharField(source='student.get_full_name', read_only=True)
    student_id = serializers.CharField(source='student.student_id', read_only=True)
    average = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    
    class Meta:
        model = Grade
        fields = [
            'id', 'student', 'student_name', 'student_id',
            'course', 'course_code', 'course_name',
            'td_mark', 'tp_mark', 'exam_mark', 'average',
            'comments', 'updated_at'
        ]
        read_only_fields = ['average']


class GradeUpdateSerializer(serializers.ModelSerializer):
    """
    Used when teacher updates marks via Flutter StudentListScreen.
    
    Flutter sends:
    {
        "td_mark": 15.5,
        "tp_mark": 16.0,
        "exam_mark": 14.0,
        "comments": "Good work"
    }
    """
    
    class Meta:
        model = Grade
        fields = ['td_mark', 'tp_mark', 'exam_mark', 'comments']


# ============================================================================
# ATTENDANCE SERIALIZERS
# ============================================================================

class AttendanceSerializer(serializers.ModelSerializer):
    """
    Attendance records for teachers to mark and students to view.
    """
    
    student_name = serializers.CharField(source='student.get_full_name', read_only=True)
    student_id = serializers.CharField(source='student.student_id', read_only=True)
    course_code = serializers.CharField(source='course.code', read_only=True)
    
    class Meta:
        model = Attendance
        fields = [
            'id', 'student', 'student_name', 'student_id',
            'course', 'course_code', 'date', 'week_number',
            'status', 'notes'
        ]


# ============================================================================
# FILE SERIALIZERS
# ============================================================================

class CourseFileSerializer(serializers.ModelSerializer):
    """
    Course files that teachers upload and students download.
    
    Flutter CourseFilesScreen receives:
    [
        {
            "id": 1,
            "title": "Lecture 1 - Introduction",
            "description": "Course introduction slides",
            "file": "http://server.com/media/course_files/lecture1.pdf",
            "file_type": "LECTURE",
            "uploaded_by_name": "Dr. Smith",
            "created_at": "2025-01-01T10:00:00Z"
        },
        ...
    ]
    """
    
    uploaded_by_name = serializers.CharField(source='uploaded_by.get_full_name', read_only=True)
    course_code = serializers.CharField(source='course.code', read_only=True)
    
    class Meta:
        model = CourseFile
        fields = [
            'id', 'course', 'course_code', 'title', 'description',
            'file', 'file_type', 'uploaded_by', 'uploaded_by_name',
            'created_at'
        ]
        read_only_fields = ['uploaded_by']


# ============================================================================
# TIMETABLE SERIALIZERS
# ============================================================================

class TimetableSerializer(serializers.ModelSerializer):
    """
    Timetable images for students to view schedules.
    
    Flutter TimetableScreen receives:
    {
        "id": 1,
        "title": "Spring 2025 Schedule",
        "image": "http://server.com/media/timetables/schedule.jpg",
        "semester": "Spring",
        "academic_year": "2024-2025"
    }
    """
    
    group_name = serializers.CharField(source='group.name', read_only=True)
    
    class Meta:
        model = Timetable
        fields = [
            'id', 'group', 'group_name', 'title', 'image',
            'semester', 'academic_year', 'is_active', 'created_at'
        ]


# ============================================================================
# NESTED SERIALIZERS FOR COMPLEX DATA
# ============================================================================

class StudentDetailSerializer(serializers.ModelSerializer):
    """
    Detailed student info for admin management.
    Includes related data like group and grades.
    """
    
    group_name = serializers.SerializerMethodField()
    grade_count = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'role',
            'student_id', 'program', 'semester', 'birth_date', 'phone', 'address',
            'profile_picture', 'is_approved', 'rejection_reason', 'group', 'group_name',
            'grade_count'
        ]
    
    def get_group_name(self, obj):
        return obj.group.name if obj.group else None
    
    def get_grade_count(self, obj):
        """How many courses this student has grades for"""
        return obj.grades.count()


class TeacherDetailSerializer(serializers.ModelSerializer):
    """
    Detailed teacher info showing assigned courses.
    """
    
    courses = CourseAssignmentSerializer(source='teaching_assignments', many=True, read_only=True)
    course_count = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'role',
            'phone', 'courses', 'course_count'
        ]
    
    def get_course_count(self, obj):
        """Number of courses this teacher is teaching"""
        return obj.teaching_assignments.count()


# ============================================================================
# INTERACTION SERIALIZERS (Messages & Notifications)
# ============================================================================

class MessageSerializer(serializers.ModelSerializer):
    """Serializer for P2P messages"""
    sender_name = serializers.CharField(source='sender.get_full_name', read_only=True)
    receiver_name = serializers.CharField(source='receiver.get_full_name', read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'sender', 'sender_name', 'receiver', 'receiver_name', 'content', 'timestamp', 'is_read']
        read_only_fields = ['sender', 'timestamp']


class NotificationSerializer(serializers.ModelSerializer):
    """Serializer for system notifications"""
    class Meta:
        model = Notification
        fields = ['id', 'user', 'title', 'message', 'notification_type', 'created_at', 'is_read']
        read_only_fields = ['created_at']
