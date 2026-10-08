from rest_framework import permissions


class IsActiveUser(permissions.BasePermission):
    message = "User account is disabled. Please contact admin."

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and getattr(request.user, "is_active", False)
        )


class IsAdmin(permissions.BasePermission):
    message = "Only administrators can perform this action."

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and getattr(request.user, "role", None) == "ADMIN"
        )
