from rest_framework import serializers
from .models import Guest, Invitation


class GuestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Guest
        fields = ['id', 'first_name', 'last_name']
        read_only_fields = ['id']


class InvitationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invitation
        fields = ['id', 'uuid', 'guest_names', 'is_plural', 'created_at']
        read_only_fields = ['id', 'uuid', 'created_at']

