import math

from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response


class MarketPagination(PageNumberPagination):
    """Custom paginator used by every list endpoint.

    - Default page size 20 (overridable per request).
    - ``?page_size=`` lets clients tune density, capped at ``max_page_size``.
    - Envelope carries ``total_pages``/``page``/``page_size`` so clients can
      drive infinite scroll without parsing URLs.
    """

    page_size = 20
    page_size_query_param = "page_size"
    max_page_size = 100

    def get_paginated_response(self, data):
        count = self.page.paginator.count
        page_size = self.get_page_size(self.request) or self.page_size
        total_pages = max(math.ceil(count / page_size), 1) if page_size else 1
        return Response(
            {
                "count": count,
                "total_pages": total_pages,
                "page": self.page.number,
                "page_size": page_size,
                "next": self.get_next_link(),
                "previous": self.get_previous_link(),
                "results": data,
            }
        )
