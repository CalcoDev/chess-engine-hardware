def number_guesser_game():
    turns = 5

    low = 0
    high = 255

    while True:
        if turns == 0:
            print("Oh no I lost!!!")
            break
        turns -= 1

        guess = (low + high) // 2

        print(f"I think your number is: {guess}.")
        response = input("Lower or higher: ")

        if response == "correct":
            print("Hahaha I win!")
            break
        elif response == "higher":
            low = guess + 1
        elif response == "lower":
            high = guess - 1
        else:
            print("No hablo.")


def main():
    print("Hello from python!")
    # number_guesser_game()


if __name__ == "__main__":
    main()
