from django.urls import path
from .views import GuestListCreateView, GuestDetailView, InvitationByUUIDView

app_name = 'guests'

urlpatterns = [
    path('', GuestListCreateView.as_view(), name='guest-list-create'),
    path('invitations/by-uuid/<uuid:uuid>/', InvitationByUUIDView.as_view(), name='invitation-by-uuid'),
    path('<int:pk>/', GuestDetailView.as_view(), name='guest-detail'),
]

