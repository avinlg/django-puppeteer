"""
URL configuration for main project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from django.http import JsonResponse, HttpResponse
from django.templatetags.static import static
import subprocess
import os

def test(request):
    return JsonResponse({"status": True, "msg": "test 2"})

def testPuppeteer(request):
    testImage = 'test-out/test.png'
    if os.path.exists(testImage):
        os.remove(testImage)
    p = subprocess.Popen(['node', 'node-build/testPuppeteer.js'], stdout=subprocess.PIPE)
    out = p.stdout.read()
    return HttpResponse(f'<img src={(static(testImage))}>')

urlpatterns = [
    path('', test),
    path('test/', testPuppeteer),
    path('admin/', admin.site.urls),
]
