##
## Makefile for project in /home/guinau_v/github/epitools/test
##
## Made by Vincent Guinaudeau
## Login  guinau_v <vincent.guinaudeau@epitech.eu>
##
## Started on  Dec 22 15:20:59 2015 Vincent Guinaudeau
## Last update Dec 22 15:20:59 2015 Vincent Guinaudeau
##

NAME	= a.out

SRC	= main.c

OBJ = $(SRC:.c=.o)

all:	$(NAME)

$(NAME):	$(OBJ)
	cc $(OBJ) -o $(NAME)

clean:
	rm -f $(OBJ)

fclean:	clean
	rm -f $(NAME)

re:	fclean all
