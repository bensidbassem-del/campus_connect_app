from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenObtainPairView

from . import views

urlpatterns = [
    # ========================================================================
    # AUTHENTICATION ENDPOINTS
    # ========================================================================
    # Flutter's auth_service.dart uses these
    
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    # POST /api/auth/register/ - Student registration
    
    path('auth/login/', views.LoginView.as_view(), name='login'),
    # POST /api/auth/login/ - Login (all roles)
    
    path('auth/logout/', views.LogoutView.as_view(), name='logout'),
    # POST /api/auth/logout/ - Logout
    
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # POST /api/auth/refresh/ - Refresh JWT token
    
    path('auth/profile/', views.UserProfileView.as_view(), name='profile'),
    # GET /api/auth/profile/ - Get current user
    # PUT /api/auth/profile/ - Update current user
    
    
    # ========================================================================
    # ADMIN ENDPOINTS - User Management
    # ========================================================================
    # Flutter's admin_service.dart uses these
    
    path('admin/pending-students/', views.PendingStudentsView.as_view(), name='pending-students'),
    # GET /api/admin/pending-students/ - List students awaiting approval
    
    path('admin/approve-student/<int:pk>/', views.ApproveStudentView.as_view(), name='approve-student'),
    # POST /api/admin/approve-student/{id}/ - Approve student registration
    
    path('admin/students/', views.StudentListView.as_view(), name='student-list'),
    # GET /api/admin/students/ - List all students
    # Query params: ?approved=true or ?approved=false
    
    path('admin/students/<int:pk>/', views.DeleteStudentView.as_view(), name='delete-student'),
    # DELETE /api/admin/students/{id}/ - Delete student
    
    path('admin/assign-group/', views.AssignStudentToGroupView.as_view(), name='assign-group'),
    # POST /api/admin/assign-group/ - Assign student to group
    
    path('admin/teachers/', views.TeacherListView.as_view(), name='teacher-list'),
    # GET /api/admin/teachers/ - List all teachers
    
    path('admin/teachers/create/', views.CreateTeacherView.as_view(), name='create-teacher'),
    # POST /api/admin/teachers/create/ - Create teacher account
    
    path('admin/teachers/<int:pk>/', views.DeleteTeacherView.as_view(), name='delete-teacher'),
    # DELETE /api/admin/teachers/{id}/ - Delete teacher
    
    
    # ========================================================================
    # COURSE ENDPOINTS
    # ========================================================================
    # Flutter's teacher_service.dart and student_service.dart use these
    
    path('courses/', views.CourseListCreateView.as_view(), name='course-list'),
    # GET /api/courses/ - List all courses
    # POST /api/courses/ - Create course (admin only)
    
    path('courses/<int:pk>/', views.CourseDetailView.as_view(), name='course-detail'),
    # GET /api/courses/{id}/ - Get course details
    # PUT /api/courses/{id}/ - Update course (admin only)
    # DELETE /api/courses/{id}/ - Delete course (admin only)
    
    path('courses/my-courses/', views.TeacherCoursesView.as_view(), name='teacher-courses'),
    # GET /api/courses/my-courses/ - Teacher's assigned courses
    
    path('courses/student-courses/', views.StudentCoursesView.as_view(), name='student-courses'),
    # GET /api/courses/student-courses/ - Student's group courses
    
    path('courses/assign-to-group/', views.AssignCourseToGroupView.as_view(), name='assign-course'),
    # POST /api/courses/assign-to-group/ - Admin assigns course to group
    
    
    # ========================================================================
    # GROUP ENDPOINTS
    # ========================================================================
    # Flutter's admin_service.dart uses these
    
    path('groups/', views.GroupListCreateView.as_view(), name='group-list'),
    # GET /api/groups/ - List all groups
    # POST /api/groups/ - Create group (admin only)
    
    path('groups/<int:pk>/', views.GroupDetailView.as_view(), name='group-detail'),
    # GET /api/groups/{id}/ - Get group details
    # PUT /api/groups/{id}/ - Update group (admin only)
    # DELETE /api/groups/{id}/ - Delete group (admin only)
    
    
    # ========================================================================
    # GRADE ENDPOINTS
    # ========================================================================
    # Flutter's teacher_service.dart and student_service.dart use these
    
    path('grades/', views.GradeListCreateView.as_view(), name='grade-list'),
    # GET /api/grades/?course_id=1 - List grades (filtered by course)
    # POST /api/grades/ - Create grade entry (teacher only)
    
    path('grades/<int:pk>/', views.GradeUpdateView.as_view(), name='grade-update'),
    # PUT /api/grades/{id}/ - Update student's grade (teacher only)
    
    path('grades/my-grades/', views.StudentGradesView.as_view(), name='my-grades'),
    # GET /api/grades/my-grades/ - Current student's grades
    
    path('grades/course/<int:course_id>/students/', views.CourseStudentsGradesView.as_view(), name='course-grades'),
    # GET /api/grades/course/{course_id}/students/ - All students in course with grades
    
    
    # ========================================================================
    # ATTENDANCE ENDPOINTS
    # ========================================================================
    # Flutter's teacher_service.dart uses these
    
    path('attendance/', views.AttendanceListCreateView.as_view(), name='attendance-list'),
    # GET /api/attendance/?course_id=1&week=1 - List attendance
    # POST /api/attendance/ - Mark attendance (teacher only)
    
    path('attendance/my-attendance/', views.StudentAttendanceView.as_view(), name='my-attendance'),
    # GET /api/attendance/my-attendance/ - Current student's attendance
    
    
    # ========================================================================
    # FILE ENDPOINTS
    # ========================================================================
    # Flutter's teacher_service.dart and student_service.dart use these
    
    path('files/', views.CourseFileListCreateView.as_view(), name='file-list'),
    # GET /api/files/?course_id=1 - List course files
    # POST /api/files/ - Upload file (teacher/admin only)
    
    path('files/<int:pk>/', views.CourseFileDetailView.as_view(), name='file-detail'),
    # GET /api/files/{id}/ - Download file
    # DELETE /api/files/{id}/ - Delete file (uploader/admin only)
    
    
    # ========================================================================
    # TIMETABLE ENDPOINTS
    # ========================================================================
    # Flutter's admin_service.dart and student_service.dart use these
    
    path('timetables/', views.TimetableListCreateView.as_view(), name='timetable-list'),
    # GET /api/timetables/ - List timetables
    # POST /api/timetables/ - Upload timetable (admin only)
    
    path('timetables/<int:pk>/', views.TimetableDetailView.as_view(), name='timetable-detail'),
    # GET /api/timetables/{id}/ - Get timetable
    # PUT /api/timetables/{id}/ - Update timetable (admin only)
    # DELETE /api/timetables/{id}/ - Delete timetable (admin only)
    
    path('timetables/my-timetable/', views.StudentTimetableView.as_view(), name='my-timetable'),
    # GET /api/timetables/my-timetable/ - Current student's group timetable
]