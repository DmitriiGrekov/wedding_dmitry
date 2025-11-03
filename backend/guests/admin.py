from django.contrib import admin
from .models import Guest, Invitation


@admin.register(Invitation)
class InvitationAdmin(admin.ModelAdmin):
    list_display = ['id', 'guest_names', 'is_plural', 'uuid', 'created_at']
    list_display_links = ['id', 'guest_names']
    search_fields = ['guest_names', 'uuid']
    list_filter = ['is_plural', 'created_at']
    readonly_fields = ['uuid', 'created_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('Информация о приглашении', {
            'fields': ('guest_names', 'is_plural')
        }),
        ('Системная информация', {
            'fields': ('uuid', 'created_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(Guest)
class GuestAdmin(admin.ModelAdmin):
    list_display = ['id', 'first_name', 'last_name']
    list_display_links = ['id', 'first_name', 'last_name']
    search_fields = ['first_name', 'last_name']
    list_filter = ['last_name']
    ordering = ['last_name', 'first_name']
