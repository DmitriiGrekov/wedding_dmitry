from django.db import models
import uuid


class Invitation(models.Model):
    """
    Модель приглашения для отображения на сайте.
    Содержит имена гостей и флаг множественного числа.
    """
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, db_index=True)
    guest_names = models.TextField(
        verbose_name='Имена гостей',
        help_text='Имена гостей для отображения на сайте (например: "Иван Иванов" или "Иван и Мария Ивановы")'
    )
    is_plural = models.BooleanField(
        default=False,
        verbose_name='Множественное число',
        help_text='Отметьте, если приглашение для нескольких человек'
    )
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    
    def __str__(self):
        return f"Приглашение для: {self.guest_names}"
    
    class Meta:
        verbose_name = "Приглашение"
        verbose_name_plural = "Приглашения"


class Guest(models.Model):
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
    
    class Meta:
        verbose_name = "Гость"
        verbose_name_plural = "Гости"