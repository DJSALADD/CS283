#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#define BUFFER_SZ 50

//prototypes
void usage(char *);
void print_buff(char *, int);
int  setup_buff(char *, char *, int);

//prototypes for functions to handle required functionality
int  count_words(char *, int, int);
int reverse_string(char *, char *, int);
int word_print(char *, int);
//add additional prototypes here
int replace_word(char *, char *, char *, int);

int reverse_string(char *buff, char *reverse_str, int str_len) {
    char *end_of_str = buff + str_len -1;
    char *beg_of_str = buff;
    char temp;

    while (beg_of_str < end_of_str) {
        temp = *beg_of_str;
        *beg_of_str = *end_of_str;
        *end_of_str = temp;


        beg_of_str++;
        end_of_str--;
    }

    char *buff_ptr = buff;
    char *reverse_ptr = reverse_str;

    for (int i = 0; i < str_len; i++) {
        *reverse_ptr = *buff_ptr;
        reverse_ptr++;
        buff_ptr++;
    }


    return 0;
}

int setup_buff(char *buff, char *user_str, int len){
    char *buff_ptr = buff;
    char *str_ptr = user_str;
    int buff_len = 0;
    int last_was_space = 0;
    int first_word = 1;

    while (*str_ptr != '\0') {
        if (*str_ptr == ' ' || *str_ptr == '\t') {
            if (first_word) {
                str_ptr++;
                continue;
            }
            else if (!last_was_space) {
                *buff_ptr = ' ';
                buff_ptr++;
                buff_len++;
                last_was_space = 1;
            }
        }
        else {
            first_word = 0;
            *buff_ptr = *str_ptr;
            buff_ptr++;
            buff_len++;
            last_was_space = 0;
        }
        str_ptr++;
    }

    if (last_was_space) {
        buff_ptr--;
    }

    while (buff_ptr < buff + len) {
        *buff_ptr = '.';
        buff_ptr++;
    }

    //user string greater than char size
    if (buff_len > len) {
        return -1;
    }
    
    return buff_len;
}

int word_print(char *buff, int str_len) {
    int wc = 0;         //counts words
    int wlen = 0;       //length of current word
    int word_start = 0;    //am I at the start of a new word

    char *buff_ptr = buff;

    printf("Word Print\n");
    printf("----------\n");

    for (int i = 0; i <= str_len - 1; i++) {
        char current_char = *buff_ptr;

        if (!word_start) {
            if (current_char == ' ') {
                continue;
            }
            wc++;
            word_start = 1;
            wlen = 0;
            printf("%d. %c", wc, current_char);
        } else {
            if (current_char != ' ') {
                printf("%c", current_char);
                wlen++;
            }
            if (current_char == ' ' || (i == ' ')) {
                printf("(%d)\n", wlen+1);
                word_start = 0;
                wlen = 0;
            }
        } 
        buff_ptr++;
    }
    printf("(%d)", wlen+1);
    return 0;
}


void print_buff(char *buff, int len){
    printf("Buffer:  [");
    for (int i=0; i<len; i++){
        putchar(*(buff+i));
    }
    putchar(']');
    putchar('\n');
}

void usage(char *exename){
    printf("usage: %s [-h|c|r|w|x] \"string\" [other args]\n", exename);

}

int count_words(char *buff, int len, int str_len){
    int wc = 0;
    int word_start = 0;
    char *ptr = buff;


    for (int i = 0; i < str_len; i++) {
        if (!word_start) {
            if (*ptr == ' ') {
                continue;
            }

            wc++;
            word_start = 1;
        } else {
            if (*ptr == ' ') {
                word_start = 0;
            }
        }
        ptr++;
    }

    return wc;
}

int replace_word(char *buff, char *replace, char *replacement, int len){
    char *buff_ptr = buff;     // Pointer to traverse the original string
    char *searchStart = NULL; // Pointer to locate the first occurrence of the search word

    char *temp_buff;
    temp_buff = (char *)malloc(BUFFER_SZ * sizeof(char));
    char *replace_ptr = replace;
    char *replacement_ptr = replacement;

    int replaceSize = 0;
    while (*replace_ptr != '\0') {
        replaceSize++;
        replace_ptr++;
    }
    replace_ptr = replace;

    // Find the first occurrence of the search word in the original string

    while (*buff_ptr != '.') {
        if (*buff_ptr == *replace_ptr) {

            char *temp_char = buff_ptr;
            char *temp_replace = replace_ptr;

            while (*temp_char == *temp_replace && *temp_replace != '\0') {
                temp_char++;
                temp_replace++;
            }

            if (*temp_replace == '\0') {
                searchStart = buff_ptr;
                break;
            }
        }
        buff_ptr++;
    }

    // If the search word is not found

    if (searchStart == NULL) {
        printf("Search word not found in the string.\n");
        return -1;
    }

    // Copy characters before the match into the buffer
    buff_ptr = buff;
    char *temp_buff_ptr = temp_buff;
    while (buff_ptr != searchStart) {
        *temp_buff_ptr = *buff_ptr;
        buff_ptr++;
        temp_buff_ptr++;
    }

    //Add the replacement
    while (*replacement_ptr != '\0') {
        *temp_buff_ptr = *replacement_ptr;
        replacement_ptr++;
        temp_buff_ptr++;
    }

    //skip ahead the replaced
    for (int i = 0; i < replaceSize; i++) {
        buff_ptr++;
    }

    //Finish copying temp_buff
    while (*buff_ptr != '.' && *buff_ptr != '\0') {
        *temp_buff_ptr = *buff_ptr;
        buff_ptr++;
        temp_buff_ptr++;
    }

    //Add . s
    while ((temp_buff_ptr - temp_buff) < len) {
        *temp_buff_ptr = '.';
        *temp_buff_ptr++;
    }


    //Lastly copy over temp_buff to buff
    temp_buff_ptr = temp_buff;
    buff_ptr = buff;
    while (*temp_buff_ptr != '\0') {
        *buff_ptr = *temp_buff_ptr;
        buff_ptr++;
        temp_buff_ptr++;
    }

    free(temp_buff);

    return 0;
}
//ADD OTHER HELPER FUNCTIONS HERE FOR OTHER REQUIRED PROGRAM OPTIONS

int main(int argc, char *argv[]){

    char *buff;             //placehoder for the internal buffer
    char *input_string;     //holds the string provided by the user on cmd line
    char opt;               //used to capture user option from cmd line
    int  rc;                //used for return codes
    int  user_str_len;      //length of user supplied string

    //TODO:  #1. WHY IS THIS SAFE, aka what if arv[1] does not exist?
    //      PLACE A COMMENT BLOCK HERE EXPLAINING
    // if arv[1] does not exist then the argc will be only 1 which is less than 2 
    // so the program will immediately only use the first argument and exit

    if ((argc < 2) || (*argv[1] != '-')){
        usage(argv[0]);
        exit(1);
    }

    opt = (char)*(argv[1]+1);   //get the option flag

    //handle the help flag and then exit normally
    if (opt == 'h'){
        usage(argv[0]);
        exit(0);
    }

    //WE NOW WILL HANDLE THE REQUIRED OPERATIONS

    //TODO:  #2 Document the purpose of the if statement below
    //      PLACE A COMMENT BLOCK HERE EXPLAINING
    // handle too many arguments by printing error message and exiting
    if (argc < 3){
        usage(argv[0]);
        exit(1);
    }

    input_string = argv[2]; //capture the user input string

    //TODO:  #3 Allocate space for the buffer using malloc and
    //          handle error if malloc fails by exiting with a 
    //          return code of 99
    // CODE GOES HERE FOR #3
    buff = (char *)malloc(BUFFER_SZ * sizeof(char));

    user_str_len = setup_buff(buff, input_string, BUFFER_SZ);
    if (user_str_len < 0){
        printf("Error setting up buffer, error = %d", user_str_len);
        exit(2);
    }

    switch (opt){
        case 'c':
            rc = count_words(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error counting words, rc = %d", rc);
                exit(2);
            }
            printf("Word Count: %d\n", rc);
            print_buff(buff,BUFFER_SZ);
            break;

        //TODO:  #5 Implement the other cases for 'r' and 'w' by extending
        //       the case statement options
        case 'r':
            char *reverse_buff;
            reverse_buff = (char *)malloc(BUFFER_SZ * sizeof(char));
            rc = reverse_string(buff, reverse_buff, user_str_len);
            if (rc < 0){
                printf("Error reversing words, rc = %d", rc);
                exit(2);
            }
            printf("Reversed String: %s\n", reverse_buff);
            free(reverse_buff);
            print_buff(buff,BUFFER_SZ);
            break;

        case 'w':
            rc = word_print(buff, user_str_len);
            if (rc < 0){
                printf("Error reversing words, rc = %d", rc);
                exit(2);
            }
            printf("\n");
            printf("\n");
            rc = count_words(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error counting words, rc = %d", rc);
                exit(2);
            }
            printf("Number of words returned: %d\n", rc);
            print_buff(buff,BUFFER_SZ);
            break;
        case 'x':
            //printf("Not Implemented!");
            char *replace = argv[3]; //capture the word to be replaced
            char *replacement = argv[4]; //capture the word to replace

            rc = replace_word(buff, replace, replacement, user_str_len);
            if (rc < 0){
                printf("Error reversing words, rc = %d", rc);
                exit(2);
            }

            print_buff(buff,BUFFER_SZ);


            break;
        default:
            usage(argv[0]);
            exit(1);
    }

    //TODO:  #6 Dont forget to free your buffer before exiting
    free(buff);
    exit(0);
}

//TODO:  #7  Notice all of the helper functions provided in the 
//          starter take both the buffer as well as the length.  Why
//          do you think providing both the pointer and the length
//          is a good practice, after all we know from main() that 
//          the buff variable will have exactly 50 bytes?
//  
//          PLACE YOUR ANSWER HERE
//          Providing the pointer and the length is good practice since the 
//          length of buff could be altered to changed dynamically at runtime,
//          and if this were the case the length argument would need to be passed.
//          By passing the length argument, we open the code to be modified easier
//          in the future.