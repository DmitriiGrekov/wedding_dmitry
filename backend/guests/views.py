from rest_framework import generics, status
from rest_framework.response import Response
from .models import Guest
from .serializers import GuestSerializer


class GuestListCreateView(generics.ListCreateAPIView):
    """
    API endpoint для получения списка гостей и создания нового гостя.
    
    GET /api/guests/ - получить список всех гостей
    POST /api/guests/ - создать нового гостя
    """
    queryset = Guest.objects.all()
    serializer_class = GuestSerializer
    
    def get_queryset(self):
        """Возвращает список всех гостей, отсортированных по фамилии"""
        return Guest.objects.all().order_by('last_name', 'first_name')


class GuestDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    API endpoint для работы с конкретным гостем.
    
    GET /api/guests/{id}/ - получить информацию о госте
    PUT /api/guests/{id}/ - обновить информацию о госте
    DELETE /api/guests/{id}/ - удалить гостя
    """
    queryset = Guest.objects.all()
    serializer_class = GuestSerializer
