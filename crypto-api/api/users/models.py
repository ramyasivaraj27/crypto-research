import uuid

from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models


class UserManager(BaseUserManager):
    def create_user(self, username=None, password=None, **extra_fields):
        if not username:
            email = extra_fields.get("email")
            if email:
                username = email
            else:
                raise ValueError("User must have a username or email.")
        email = extra_fields.get("email")
        if email:
            extra_fields["email"] = self.normalize_email(email)
        user = self.model(username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username=None, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_verified", True)
        return self.create_user(username, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    class Role(models.TextChoices):
        VIEWER = "VIEWER", "Viewer"
        RESEARCHER = "RESEARCHER", "Researcher"
        ADMIN = "ADMIN", "Admin"

    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    username = models.CharField(max_length=150, unique=True, db_index=True)
    email = models.EmailField(max_length=255, blank=True, null=True)
    name = models.CharField(max_length=255, blank=True, default="")
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_verified = models.BooleanField(default=False)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.RESEARCHER)

    objects = UserManager()

    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = ["email"]

    class Meta:
        indexes = [
            models.Index(fields=["username"], name="user_username_idx"),
            models.Index(fields=["role"], name="user_role_idx"),
        ]

    def __str__(self):
        return self.username
