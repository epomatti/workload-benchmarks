from django.db import models


PET_CHOICES = (("cat", "cat"), ("dog", "dog"))


class Owner(models.Model):
    name = models.CharField(max_length=30)
    birthday = models.DateField()


class Pet(models.Model):
    owner = models.ForeignKey(Owner, on_delete=models.CASCADE)
    name = models.CharField(max_length=30)
    age = models.IntegerField()
    type = models.CharField(max_length=30, choices=PET_CHOICES)
    breed = models.CharField(max_length=30)
