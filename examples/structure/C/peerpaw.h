/* Autogenerated with DRAKON Editor 1.23 */
#ifndef PEERPAW_H68313
#define PEERPAW_H68313

#include "lib.h"

typedef struct peerpaw peerpaw;
typedef struct employee employee;
typedef int (*employee_fun)(employee* item, void* user_data /* null */);
typedef struct department department;
typedef int (*department_fun)(department* item, void* user_data /* null */);


peerpaw* /* own */
peerpaw_create(void);


void
peerpaw_destroy(peerpaw* me /* own. null */);


int
peerpaw_error(const peerpaw* db);


int
employee_id(const employee* me);


employee* /* null */
peerpaw_get_employee(peerpaw* db,
    int rec_id);


const string8* /* null */
employee_cget_name(const employee* me);


int
peerpaw_set_employee_department(peerpaw* db,
    employee* _record_,
    department* new_value /* null */);


employee* /* null */
peerpaw_insert_employee(peerpaw* db,
    string8* name /* own. null */,
    department* department /* null */);


int
peerpaw_delete_employee(peerpaw* db,
    employee* record /* null */);


int
peerpaw_employee_count(const peerpaw* db);


int
peerpaw_foreach_employee(peerpaw* db,
    employee_fun visitor,
    void* user_data /* null */);


employee* /* null */
peerpaw_employee_by_department_name(peerpaw* db,
    const department* department /* null */,
    const string8* name /* null */);


int
department_id(const department* me);


department* /* null */
peerpaw_get_department(peerpaw* db,
    int rec_id);


int
department_employees_count(const department* record);


employee*
department_employees(department* record,
    int index);


department* /* null */
peerpaw_insert_department(peerpaw* db,
    string8* title /* own. null */);


int
peerpaw_delete_department(peerpaw* db,
    department* record /* null */);


int
peerpaw_department_count(const peerpaw* db);


int
peerpaw_foreach_department(peerpaw* db,
    department_fun visitor,
    void* user_data /* null */);


department* /* null */
peerpaw_department_by_title(peerpaw* db,
    const string8* title /* null */);






int main(
    int argc,
    char** argv
);


#endif

