from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Guest, Invitation
from .serializers import GuestSerializer, InvitationSerializer


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


class InvitationByUUIDView(APIView):
    """
    API endpoint для получения информации о приглашении по UUID.
    
    GET /api/invitations/by-uuid/{uuid}/ - получить информацию о приглашении
    """
    
    def get(self, request, uuid):
        try:
            invitation = Invitation.objects.get(uuid=uuid)
            serializer = InvitationSerializer(invitation)
            return Response(serializer.data)
            
        except Invitation.DoesNotExist:
            return Response(
                {'error': 'Приглашение с таким UUID не найдено'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
