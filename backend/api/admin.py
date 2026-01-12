"""
Campus Connect - Django Admin Configuration
This allows you to manage data through Django's admin panel at:
http://localhost:8000/admin/

Useful for:
- Creating initial teacher accounts
- Creating test data
- Debugging database issues
- Manual approvals during testing
"""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Course, Group, Grade, Attendance, CourseFile, Timetable, CourseAssignment


# ============================================================================
# CUSTOM USER ADMIN
# ============================================================================
@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """
    Enhanced admin interface for User model.
    Shows custom fields like role, student_id, is_approved, etc.
    """
    
    # What to display in the list view
    list_display = ['username', 'email', 'role', 'first_name', 'last_name', 'is_approved', 'group']
    list_filter = ['role', 'is_approved', 'group']
    search_fields = ['username', 'email', 'first_name', 'last_name', 'student_id']
    
    # Edit form
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Campus Connect Info', {
            'fields': ('role', 'student_id', 'program', 'semester', 'birth_date', 'phone', 'address', 
                      'profile_picture', 'is_approved', 'rejection_reason', 'group')
        }),
    )
    
    # Add form (when creating new user)
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ('Campus Connect Info', {
            'fields': ('role', 'student_id', 'program', 'semester', 'is_approved', 'group')
        }),
    )
    
    # Quick actions
    actions = ['approve_students', 'reject_students']
    
    def approve_students(self, request, queryset):
        """Bulk approve selected students"""
        count = queryset.filter(role=User.STUDENT).update(is_approved=True)
        self.message_user(request, f'{count} student(s) approved successfully.')
    approve_students.short_description = 'Approve selected students'
    
    def reject_students(self, request, queryset):
        """Bulk reject selected students"""
        count = queryset.filter(role=User.STUDENT).update(is_approved=False)
        self.message_user(request, f'{count} student(s) marked as pending.')
    reject_students.short_description = 'Mark as pending'


# ============================================================================
# COURSE ADMIN
# ============================================================================
@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    """Admin interface for Course management"""
    
    list_display = ['code', 'name', 'credits', 'created_at']
    list_filter = ['credits']
    search_fields = ['code', 'name']
    
    # Show related info
    filter_horizontal = []  # For many-to-many fields if needed
    
    fieldsets = (
        ('Course Information', {
            'fields': ('code', 'name', 'description', 'credits')
        }),
    )


# ============================================================================
# GROUP ADMIN
# ============================================================================
@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    """Admin interface for Group management"""
    
    list_display = ['name', 'academic_year', 'student_count', 'course_count', 'created_at']
    list_filter = ['academic_year']
    search_fields = ['name']
    filter_horizontal = ['courses']  # Nice UI for assigning courses
    
    def student_count(self, obj):
        """Show number of students in this group"""
        return obj.students.count()
    student_count.short_description = 'Students'
    
    def course_count(self, obj):
        """Show number of courses assigned to this group"""
        return obj.courses.count()
    course_count.short_description = 'Courses'


# ============================================================================
# GRADE ADMIN
# ============================================================================
@admin.register(Grade)
class GradeAdmin(admin.ModelAdmin):
    """Admin interface for Grade management"""
    
    list_display = ['student', 'course', 'td_mark', 'tp_mark', 'exam_mark', 'average', 'updated_at']
    list_filter = ['course', 'student__group']
    search_fields = ['student__username', 'student__student_id', 'course__code']
    
    fieldsets = (
        ('Student & Course', {
            'fields': ('student', 'course')
        }),
        ('Marks', {
            'fields': ('td_mark', 'tp_mark', 'exam_mark', 'comments')
        }),
    )
    
    readonly_fields = ['created_at', 'updated_at']
    
    def average(self, obj):
        """Display calculated average"""
        return obj.average or 'N/A'
    average.short_description = 'Average'


# ============================================================================
# ATTENDANCE ADMIN
# ============================================================================
@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    """Admin interface for Attendance management"""
    
    list_display = ['student', 'course', 'date', 'week_number', 'status']
    list_filter = ['status', 'course', 'date', 'week_number']
    search_fields = ['student__username', 'course__code']
    date_hierarchy = 'date'
    
    fieldsets = (
        ('Attendance Info', {
            'fields': ('student', 'course', 'date', 'week_number')
        }),
        ('Status', {
            'fields': ('status', 'notes')
        }),
    )


# ============================================================================
# COURSE FILE ADMIN
# ============================================================================
@admin.register(CourseFile)
class CourseFileAdmin(admin.ModelAdmin):
    """Admin interface for Course File management"""
    
    list_display = ['title', 'course', 'file_type', 'uploaded_by', 'created_at']
    list_filter = ['file_type', 'course', 'created_at']
    search_fields = ['title', 'course__code', 'uploaded_by__username']
    date_hierarchy = 'created_at'
    
    fieldsets = (
        ('File Information', {
            'fields': ('course', 'title', 'description', 'file', 'file_type')
        }),
        ('Upload Info', {
            'fields': ('uploaded_by',)
        }),
    )
    
    readonly_fields = ['uploaded_by', 'created_at']
    
    def save_model(self, request, obj, form, change):
        """Automatically set uploaded_by to current admin user"""
        if not change:  # If creating new object
            obj.uploaded_by = request.user
        super().save_model(request, obj, form, change)


# ============================================================================
# TIMETABLE ADMIN
# ============================================================================
@admin.register(Timetable)
class TimetableAdmin(admin.ModelAdmin):
    """Admin interface for Timetable management"""
    
    list_display = ['title', 'group', 'semester', 'academic_year', 'is_active', 'created_at']
    list_filter = ['is_active', 'group', 'semester', 'academic_year']
    search_fields = ['title', 'group__name']
    
    fieldsets = (
        ('Timetable Information', {
            'fields': ('group', 'title', 'image')
        }),
        ('Academic Period', {
            'fields': ('semester', 'academic_year', 'is_active')
        }),
    )
    
    actions = ['activate_timetables', 'deactivate_timetables']
    
    def activate_timetables(self, request, queryset):
        """Set selected timetables as active"""
        count = queryset.update(is_active=True)
        self.message_user(request, f'{count} timetable(s) activated.')
    activate_timetables.short_description = 'Activate selected timetables'
    
    def deactivate_timetables(self, request, queryset):
        """Set selected timetables as inactive"""
        count = queryset.update(is_active=False)
        self.message_user(request, f'{count} timetable(s) deactivated.')
    deactivate_timetables.short_description = 'Deactivate selected timetables'


# ============================================================================
# COURSE ASSIGNMENT ADMIN
# ============================================================================
@admin.register(CourseAssignment)
class CourseAssignmentAdmin(admin.ModelAdmin):
    """Admin interface for Course-Teacher-Group assignments"""
    
    list_display = ['teacher', 'course', 'group', 'academic_year']
    list_filter = ['academic_year', 'group', 'teacher', 'course']
    search_fields = ['teacher__username', 'course__name', 'group__name']


# ============================================================================
# CUSTOMIZE ADMIN SITE
# ============================================================================
admin.site.site_header = "Campus Connect Administration"
admin.site.site_title = "Campus Connect Admin"
admin.site.index_title = "Welcome to Campus Connect Admin Panel" 