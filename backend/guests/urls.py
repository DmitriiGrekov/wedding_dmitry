from django.urls import path
from .views import GuestListCreateView, GuestDetailView

app_name = 'guests'

urlpatterns = [
    path('', GuestListCreateView.as_view(), name='guest-list-create'),
    path('<int:pk>/', GuestDetailView.as_view(), name='guest-detail'),
]

