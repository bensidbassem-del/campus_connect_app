"""
Campus Connect - API Views (Complete File)
These views handle HTTP requests from Flutter and return JSON responses.
Each view is an API endpoint that Flutter's service classes call.

URL Pattern in Flutter:
http://your-server/api/endpoint-name/
"""

from rest_framework import generics, status, permissions, filters
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404
from django.db.models import Q
from django_filters.rest_framework import DjangoFilterBackend

from .models import User, Course, Group, Grade, Attendance, CourseFile, Timetable, CourseAssignment, Message, Notification
from .serializers import *
from .permissions import IsAdmin, IsTeacher, IsStudent, IsApprovedStudent


# ============================================================================
# AUTHENTICATION VIEWS
# ============================================================================

class RegisterView(generics.CreateAPIView):
    """
    Student Registration Endpoint
    
    Flutter Connection: RegisterScreen → POST /api/auth/register/
    
    Flutter sends:
    {
        "username": "student123",
        "email": "student@example.com",
        "password": "securepass",
        "password2": "securepass",
        "first_name": "John",
        "last_name": "Doe",
        "student_id": "192031234",
        ...
    }
    
    Returns:
    {
        "message": "Registration successful. Awaiting admin approval.",
        "user": {user data}
    }
    
    After this, student goes to PendingApprovalScreen in Flutter.
    """
    
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]  # Anyone can register
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        return Response({
            'message': 'Registration successful. Awaiting admin approval.',
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """
    Login Endpoint for all roles
    
    Flutter Connection: LoginScreen → POST /api/auth/login/
    
    Flutter sends:
    {
        "username": "student123",
        "password": "password123"
    }
    
    Returns:
    {
        "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",  // JWT token
        "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
        "user": {
            "id": 1,
            "username": "student123",
            "role": "STUDENT",
            "email": "student@example.com",
            ...
        }
    }
    
    Flutter stores the access token and uses it for all future requests.
    Flutter's AuthGate uses the role to navigate:
    - ADMIN → AdminHomeScreen
    - TEACHER → TeacherHomeScreen
    - STUDENT → StudentHomeScreen
    """
    
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        
        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user).data
        })


class LogoutView(APIView):
    """
    Logout Endpoint
    
    Flutter Connection: Any screen → POST /api/auth/logout/
    
    Flutter clears local storage and navigates to LoginScreen.
    
    Note: This simple version doesn't blacklist tokens. 
    For token blacklisting, add 'rest_framework_simplejwt.token_blacklist' to INSTALLED_APPS
    """
    
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        # Simple logout - just return success
        # Token invalidation happens client-side when Flutter clears storage
        return Response({'message': 'Logout successful'}, status=status.HTTP_200_OK)


class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    Get/Update Current User Profile
    
    Flutter Connection: ProfileScreen → GET/PUT /api/auth/profile/
    
    GET returns current user's data
    PUT updates user info (student can update phone, address, etc.)
    
    Flutter's StudentCardScreen uses this to display and edit profile.
    """
    
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user


# ============================================================================
# ADMIN VIEWS - User Management
# ============================================================================

class PendingStudentsView(generics.ListAPIView):
    """
    List all students waiting for approval
    
    Flutter Connection: AdminHomeScreen → GET /api/admin/pending-students/
    
    Returns:
    [
        {
            "id": 1,
            "username": "newstudent",
            "email": "new@example.com",
            "first_name": "John",
            "last_name": "Doe",
            "is_approved": false
        },
        ...
    ]
    
    Admin sees these in ManageStudentsScreen and can approve/delete.
    """
    
    serializer_class = StudentDetailSerializer
    permission_classes = [IsAdmin]
    
    def get_queryset(self):
        return User.objects.filter(role=User.STUDENT, is_approved=False)


class ApproveStudentView(APIView):
    """
    Approve a student registration
    
    Flutter Connection: ManageStudentsScreen → POST /api/admin/approve-student/{id}/
    
    Admin clicks "Approve" button in Flutter → this sets is_approved=True
    Now student can login.
    """
    
    permission_classes = [IsAdmin]

    def post(self, request, pk):
        try:
            student = User.objects.get(pk=pk, role=User.STUDENT)
            student.is_approved = True
            student.rejection_reason = None # Clear any previous rejection
            student.save()
            return Response({
                'message': 'Student approved successfully',
                'student': UserSerializer(student).data
            })
        except User.DoesNotExist:
            return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)
    
class RejectStudentView(APIView):
    """
    Reject a student registration with a reason.
    
    Flutter Connection: ManageStudentsScreen → POST /api/admin/reject-student/{id}/
    """
    permission_classes = [IsAdmin]

    def post(self, request, pk):
        reason = request.data.get('reason', 'Requirements not met')
        try:
            student = User.objects.get(pk=pk, role=User.STUDENT)
            student.is_approved = False
            student.rejection_reason = reason
            student.save()
            return Response({'message': 'Student rejected', 'reason': reason})
        except User.DoesNotExist:
            return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)


class DeleteStudentView(generics.DestroyAPIView):
    """
    Delete a student account
    
    Flutter Connection: ManageStudentsScreen → DELETE /api/admin/students/{id}/
    
    Admin can delete pending or approved students.
    """
    
    permission_classes = [IsAdmin]
    queryset = User.objects.filter(role=User.STUDENT)


class StudentListView(generics.ListAPIView):
    """
    List all students with advanced search and filtering (Sprint 4)
    """
    serializer_class = StudentDetailSerializer
    permission_classes = [IsAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_approved', 'group', 'program', 'semester']
    search_fields = ['username', 'first_name', 'last_name', 'email', 'student_id']
    ordering_fields = ['username', 'created_at', 'student_id']
    
    def get_queryset(self):
        return User.objects.filter(role=User.STUDENT)


class AssignStudentToGroupView(APIView):
    """
    Assign a student to a group
    
    Flutter Connection: ManageStudentsScreen → POST /api/admin/assign-group/
    
    Flutter sends:
    {
        "student_id": 1,
        "group_id": 2
    }
    """
    
    permission_classes = [IsAdmin]
    
    def post(self, request):
        student_id = request.data.get('student_id')
        group_id = request.data.get('group_id')
        
        try:
            student = User.objects.get(pk=student_id, role=User.STUDENT)
            group = Group.objects.get(pk=group_id)
            
            student.group = group
            student.save()
            
            return Response({
                'message': f'Student assigned to {group.name}',
                'student': UserSerializer(student).data
            })
        except User.DoesNotExist:
            return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)
        except Group.DoesNotExist:
            return Response({'error': 'Group not found'}, status=status.HTTP_404_NOT_FOUND)


class TeacherListView(generics.ListAPIView):
    """
    List all teachers with search (Sprint 4)
    """
    serializer_class = TeacherDetailSerializer
    permission_classes = [IsAdmin]
    filter_backends = [filters.SearchFilter]
    search_fields = ['username', 'first_name', 'last_name', 'email']
    queryset = User.objects.filter(role=User.TEACHER)


class CreateTeacherView(generics.CreateAPIView):
    """
    Create a new teacher account
    
    Flutter Connection: ManageTeachersScreen → POST /api/admin/teachers/
    
    Admin creates predefined teacher accounts.
    Flutter sends:
    {
        "username": "teacher1",
        "email": "teacher@example.com",
        "password": "teacherpass",
        "first_name": "Dr.",
        "last_name": "Smith"
    }
    """
    
    permission_classes = [IsAdmin]
    
    def post(self, request):
        data = request.data
        
        # Validate required fields
        required = ['username', 'email', 'password']
        if not all(field in data for field in required):
            return Response(
                {'error': 'Missing required fields'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Create teacher
        teacher = User.objects.create_user(
            username=data['username'],
            email=data['email'],
            password=data['password'],
            first_name=data.get('first_name', ''),
            last_name=data.get('last_name', ''),
            role=User.TEACHER,
            is_approved=True  # Teachers are auto-approved
        )
        
        return Response({
            'message': 'Teacher created successfully',
            'teacher': UserSerializer(teacher).data
        }, status=status.HTTP_201_CREATED)


class DeleteTeacherView(generics.DestroyAPIView):
    """
    Delete a teacher account
    
    Flutter Connection: ManageTeachersScreen → DELETE /api/admin/teachers/{id}/
    """
    
    permission_classes = [IsAdmin]
    queryset = User.objects.filter(role=User.TEACHER)


# ============================================================================
# COURSE MANAGEMENT VIEWS
# ============================================================================

class CourseListCreateView(generics.ListCreateAPIView):
    """
    List all courses or create new course
    
    Flutter Connection:
    - GET /api/courses/ → ManageCoursesScreen (admin) or MyCoursesScreen
    - POST /api/courses/ → Admin creates course
    
    POST body:
    {
        "code": "DAM301",
        "name": "Mobile Development",
        "description": "Learn Flutter...",
        "credits": 3,
        "teacher": 2  // teacher ID
    }
    """
    
    queryset = Course.objects.all()
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['code', 'name']
    ordering_fields = ['code', 'name', 'credits']
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return CourseCreateSerializer
        return CourseSerializer
    
    def get_permissions(self):
        # Only admin can create courses
        if self.request.method == 'POST':
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class CourseDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Get, Update, or Delete a specific course
    
    Flutter Connection:
    - GET /api/courses/{id}/ → View course details
    - PUT /api/courses/{id}/ → Admin updates course
    - DELETE /api/courses/{id}/ → Admin deletes course
    """
    
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    
    def get_permissions(self):
        # Only admin can update/delete
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class TeacherCoursesView(generics.ListAPIView):
    """
    Get courses assigned to current teacher via CourseAssignment
    """
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        return CourseAssignment.objects.filter(teacher=self.request.user)


class StudentCoursesView(generics.ListAPIView):
    """
    Get courses for current student's group via CourseAssignment
    """
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsStudent]
    
    def get_queryset(self):
        student = self.request.user
        if student.group:
            return CourseAssignment.objects.filter(group=student.group)
        return CourseAssignment.objects.none()


class AssignCourseToGroupView(APIView):
    """
    Assign a course to a group
    
    Flutter Connection: ManageCoursesScreen → POST /api/courses/assign-to-group/
    
    Flutter sends:
    {
        "course_id": 1,
        "group_id": 2
    }
    """
    
    permission_classes = [IsAdmin]
    
    def post(self, request):
        course_id = request.data.get('course_id')
        group_id = request.data.get('group_id')
        
        try:
            course = Course.objects.get(pk=course_id)
            group = Group.objects.get(pk=group_id)
            
            group.courses.add(course)
            
            return Response({
                'message': f'Course {course.code} assigned to {group.name}',
                'course': CourseSerializer(course).data
            })
        except Course.DoesNotExist:
            return Response({'error': 'Course not found'}, status=status.HTTP_404_NOT_FOUND)
        except Group.DoesNotExist:
            return Response({'error': 'Group not found'}, status=status.HTTP_404_NOT_FOUND)


# ============================================================================
# GROUP MANAGEMENT VIEWS
# ============================================================================

class GroupListCreateView(generics.ListCreateAPIView):
    """
    List all groups or create new group
    
    Flutter Connection:
    - GET /api/groups/ → AdminHomeScreen
    - POST /api/groups/ → Admin creates group
    
    POST body:
    {
        "name": "IFA G1",
        "academic_year": "2024-2025"
    }
    """
    
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    
    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class GroupDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Get, Update, or Delete a specific group
    """
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    
    def get_permissions(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


# ============================================================================
# COURSE ASSIGNMENT VIEWS (Admin)
# ============================================================================

class CourseAssignmentListCreateView(generics.ListCreateAPIView):
    """
    Admin manages teachers assignment to courses and groups.
    """
    queryset = CourseAssignment.objects.all()
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsAdmin]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['group', 'teacher', 'course']


class CourseAssignmentDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = CourseAssignment.objects.all()
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsAdmin]


# ============================================================================
# GRADE MANAGEMENT VIEWS
# ============================================================================

class GradeListCreateView(generics.ListCreateAPIView):
    """
    List grades or create new grade entry
    
    Flutter Connection:
    - GET /api/grades/?course_id=1 → Teacher sees all students' grades for a course
    - POST /api/grades/ → Teacher creates grade for a student
    
    POST body:
    {
        "student": 1,
        "course": 1,
        "td_mark": 15.5,
        "tp_mark": 16.0,
        "exam_mark": 14.0,
        "comments": "Good work"
    }
    """
    
    serializer_class = GradeSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        queryset = Grade.objects.all()
        
        # Filter by course if specified
        course_id = self.request.query_params.get('course_id')
        if course_id:
            queryset = queryset.filter(course_id=course_id)
        
        # Teachers only see grades for their courses
        if self.request.user.role == User.TEACHER:
            queryset = queryset.filter(course__teacher=self.request.user)
        
        return queryset


class GradeUpdateView(generics.UpdateAPIView):
    """
    Update a student's grade
    
    Flutter Connection: StudentListScreen → PUT /api/grades/{id}/
    
    Teacher updates marks:
    {
        "td_mark": 16.5,
        "tp_mark": 17.0,
        "exam_mark": 15.5,
        "comments": "Excellent improvement"
    }
    """
    
    queryset = Grade.objects.all()
    serializer_class = GradeUpdateSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        # Teachers can only update grades for their courses
        return Grade.objects.filter(course__teacher=self.request.user)


class StudentGradesView(generics.ListAPIView):
    """
    Get current student's grades
    
    Flutter Connection: MarksScreen → GET /api/grades/my-grades/
    
    Returns all grades for the logged-in student:
    [
        {
            "course_code": "DAM301",
            "course_name": "Mobile Development",
            "td_mark": 15.5,
            "tp_mark": 16.0,
            "exam_mark": 14.0,
            "average": 15.17
        },
        ...
    ]
    """
    
    serializer_class = GradeSerializer
    permission_classes = [IsStudent]
    
    def get_queryset(self):
        return Grade.objects.filter(student=self.request.user)


class CourseStudentsGradesView(generics.ListAPIView):
    """
    Get all students and their grades for a specific course
    
    Flutter Connection: StudentListScreen → GET /api/grades/course/{course_id}/students/
    
    Teacher uses this to see all students in a course and their marks.
    """
    
    serializer_class = GradeSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        course_id = self.kwargs['course_id']
        
        # Verify teacher teaches this course
        course = get_object_or_404(Course, pk=course_id, teacher=self.request.user)
        
        # Get or create grade entries for all students in groups taking this course
        students = User.objects.filter(
            role=User.STUDENT,
            group__courses=course
        )
        
        # Create grade entries if they don't exist
        for student in students:
            Grade.objects.get_or_create(
                student=student,
                course=course
            )
        
        return Grade.objects.filter(course=course)


# ============================================================================
# ATTENDANCE VIEWS
# ============================================================================

class AttendanceListCreateView(generics.ListCreateAPIView):
    """
    List attendance or mark attendance
    
    Flutter Connection:
    - GET /api/attendance/?course_id=1&week=1 → View attendance
    - POST /api/attendance/ → Mark attendance
    
    POST body:
    {
        "student": 1,
        "course": 1,
        "date": "2025-01-15",
        "week_number": 1,
        "status": "PRESENT"
    }
    """
    
    serializer_class = AttendanceSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        queryset = Attendance.objects.filter(course__teacher=self.request.user)
        
        course_id = self.request.query_params.get('course_id')
        week = self.request.query_params.get('week')
        
        if course_id:
            queryset = queryset.filter(course_id=course_id)
        if week:
            queryset = queryset.filter(week_number=week)
        
        return queryset


class StudentAttendanceView(generics.ListAPIView):
    """
    Get current student's attendance records
    
    Flutter Connection: Student views → GET /api/attendance/my-attendance/
    """
    
    serializer_class = AttendanceSerializer
    permission_classes = [IsStudent]
    
    def get_queryset(self):
        return Attendance.objects.filter(student=self.request.user)


# ============================================================================
# FILE MANAGEMENT VIEWS
# ============================================================================

class CourseFileListCreateView(generics.ListCreateAPIView):
    """
    List files or upload new file
    
    Flutter Connection:
    - GET /api/files/?course_id=1 → CourseFilesScreen shows files
    - POST /api/files/ → UploadCourseFilesScreen uploads file
    
    POST (multipart/form-data):
    {
        "course": 1,
        "title": "Lecture 1",
        "description": "Introduction slides",
        "file": <file>,
        "file_type": "LECTURE"
    }
    """
    
    serializer_class = CourseFileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        queryset = CourseFile.objects.all()
        
        course_id = self.request.query_params.get('course_id')
        if course_id:
            queryset = queryset.filter(course_id=course_id)
        
        # Students only see files for their courses
        if self.request.user.role == User.STUDENT:
            if self.request.user.group:
                queryset = queryset.filter(course__groups=self.request.user.group)
            else:
                queryset = CourseFile.objects.none()
        
        # Teachers only see files for their courses
        elif self.request.user.role == User.TEACHER:
            queryset = queryset.filter(course__teacher=self.request.user)
        
        return queryset
    
    def perform_create(self, serializer):
        # Set uploaded_by to current user
        serializer.save(uploaded_by=self.request.user)


class CourseFileDetailView(generics.RetrieveDestroyAPIView):
    """
    Get or delete a specific file
    
    Flutter Connection:
    - GET /api/files/{id}/ → Download/view file
    - DELETE /api/files/{id}/ → Teacher/Admin deletes file
    """
    
    queryset = CourseFile.objects.all()
    serializer_class = CourseFileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_permissions(self):
        if self.request.method == 'DELETE':
            # Only uploader or admin can delete
            return [permissions.IsAuthenticated()]
        return [permissions.IsAuthenticated()]
    
    def perform_destroy(self, instance):
        # Check if user is the uploader or admin
        if instance.uploaded_by == self.request.user or self.request.user.role == User.ADMIN:
            instance.delete()
        else:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You don't have permission to delete this file")


# ============================================================================
# TIMETABLE VIEWS
# ============================================================================

class TimetableListCreateView(generics.ListCreateAPIView):
    """
    List timetables or upload new timetable
    
    Flutter Connection:
    - GET /api/timetables/ → TimetableScreen shows schedules
    - POST /api/timetables/ → UploadTimetableScreen (admin) uploads
    
    POST (multipart/form-data):
    {
        "group": 1,
        "title": "Spring 2025 Schedule",
        "image": <image_file>,
        "semester": "Spring",
        "academic_year": "2024-2025",
        "is_active": true
    }
    """
    
    serializer_class = TimetableSerializer
    
    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]
    
    def get_queryset(self):
        queryset = Timetable.objects.filter(is_active=True)
        
        # Students see timetables for their group
        if self.request.user.role == User.STUDENT:
            if self.request.user.group:
                queryset = queryset.filter(group=self.request.user.group)
            else:
                queryset = Timetable.objects.none()
        
        return queryset


class TimetableDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Get, Update, or Delete a timetable
    
    Flutter Connection:
    - GET /api/timetables/{id}/ → View timetable
    - PUT /api/timetables/{id}/ → Admin updates
    - DELETE /api/timetables/{id}/ → Admin deletes
    """
    
    queryset = Timetable.objects.all()
    serializer_class = TimetableSerializer
    
    def get_permissions(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class StudentTimetableView(APIView):
    """
    Get current student's active timetable
    
    Flutter Connection: TimetableScreen → GET /api/timetables/my-timetable/
    
    Returns the active timetable for student's group.
    """
    
    permission_classes = [IsStudent]
    
    def get(self, request):
        student = request.user
        
        if not student.group:
            return Response(
                {'message': 'You are not assigned to any group yet'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        timetable = Timetable.objects.filter(
            group=student.group,
            is_active=True
        ).first()
        
        if not timetable:
            return Response(
                {'message': 'No timetable available for your group'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        return Response(TimetableSerializer(timetable).data)


# ============================================================================
# INTERACTION VIEWS (Messages & Notifications)
# ============================================================================

class NotificationListView(generics.ListAPIView):
    """
    List notifications for current user
    
    Flutter Connection: GET /api/notifications/
    """
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)


class NotificationMarkReadView(APIView):
    """
    Mark a notification as read
    
    Flutter Connection: POST /api/notifications/{id}/read/
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        notification = get_object_or_404(Notification, pk=pk, user=request.user)
        notification.is_read = True
        notification.save()
        return Response({'status': 'notification marked as read'})


class MessageListCreateView(generics.ListCreateAPIView):
    """
    List messages with a specific user or send a new message
    
    Flutter Connection:
    - GET /api/messages/?with_user=2
    - POST /api/messages/
    """
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        other_user_id = self.request.query_params.get('with_user')
        if not other_user_id:
            # Return all conversations summary (simplified for now)
            return Message.objects.filter(
                Q(sender=self.request.user) | Q(receiver=self.request.user)
            )
        
        return Message.objects.filter(
            (Q(sender=self.request.user) & Q(receiver_id=other_user_id)) |
            (Q(sender_id=other_user_id) & Q(receiver=self.request.user))
        )

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)
