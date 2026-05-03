#!/bin/bash
# grade.sh — Display all student solution submissions for review
#
# Prints each student's answer.txt, preceded by their username and status.
# Provides a submitted/not-submitted summary at the end.
#
# Usage:
#   sudo bash setup/grade.sh setup/students.csv
#
# Without a CSV, falls back to all members of the 'students' group:
#   sudo bash setup/grade.sh

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root." >&2
    exit 1
fi

CSV_FILE="${1:-}"
STUDENTS_GROUP="students"

DIVIDER="============================================================"
SUBDIV="------------------------------------------------------------"

echo "$DIVIDER"
echo "  MASON HIGH SCHOOL — COMET MYSTERY GRADING REPORT"
printf "  Generated: %s\n" "$(date)"
echo "$DIVIDER"
echo ""

submitted=0
not_submitted=0

grade_student() {
    local username="$1"
    local solution_file="/home/$username/solution/answer.txt"

    echo "$SUBDIV"
    printf "  Student : %s\n" "$username"

    if [ -f "$solution_file" ]; then
        printf "  Status  : [SUBMITTED]\n"
        echo ""
        # Indent each line of the submission for readability
        sed 's/^/    /' "$solution_file"
    else
        printf "  Status  : [NOT SUBMITTED]\n"
        if [ -d "/home/$username/solution" ]; then
            echo "  Note    : solution/ directory exists but answer.txt is missing"
        fi
    fi
    echo ""
}

if [ -n "$CSV_FILE" ] && [ -f "$CSV_FILE" ]; then
    line_num=0
    while IFS=',' read -r username rest; do
        line_num=$((line_num + 1))
        [ "$line_num" -eq 1 ] && [ "$username" = "username" ] && continue
        [ -z "$username" ] && continue
        username=$(echo "$username" | tr -d '[:space:]')
        if ! id "$username" &>/dev/null; then
            continue
        fi
        grade_student "$username"
        if [ -f "/home/$username/solution/answer.txt" ]; then
            submitted=$((submitted + 1))
        else
            not_submitted=$((not_submitted + 1))
        fi
    done < "$CSV_FILE"

else
    echo "  (No CSV provided — checking all members of group '$STUDENTS_GROUP')"
    echo ""

    if ! getent group "$STUDENTS_GROUP" > /dev/null 2>&1; then
        echo "ERROR: Group '$STUDENTS_GROUP' not found. Pass a CSV file instead." >&2
        exit 1
    fi

    # Parse the group member list into one username per line
    mapfile -t student_list < <(
        getent group "$STUDENTS_GROUP" \
        | cut -d: -f4 \
        | tr ',' '\n' \
        | sort \
        | grep -v '^$'
    )

    for username in "${student_list[@]}"; do
        grade_student "$username"
        if [ -f "/home/$username/solution/answer.txt" ]; then
            submitted=$((submitted + 1))
        else
            not_submitted=$((not_submitted + 1))
        fi
    done
fi

total=$((submitted + not_submitted))

echo "$DIVIDER"
echo "  SUMMARY"
printf "  Submitted     : %d / %d\n" "$submitted" "$total"
printf "  Not submitted : %d / %d\n" "$not_submitted" "$total"
echo "$DIVIDER"
