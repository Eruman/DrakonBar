// Autogenerated with DRAKON Editor 1.25
using System;
using System.Linq;
using System.Collections.Generic;
using System.Collections.ObjectModel;

class Bar {
	public delegate void AnyCode();

	public class FakeEmployee : IEmployee {
		public int Id { get; set; }
		public string Name { get; set; }
        		public ReadOnlyCollection<IDepartment> Departments { get { return null; } }
        		public ICompany Company { get { return null; } }

	}
    public interface IBaseRecord
    {
        int Id { get; }
    }
    private interface IDelRecord
    {
        void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master);
        void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList);
        void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList);
    }
    public interface ICompany : IBaseRecord {
        ReadOnlyCollection<IDepartment> Departments { get; }
        ReadOnlyCollection<IEmployee> Employees { get; }
    }
    public interface IEmployee : IBaseRecord {
        string Name { get; }
        ICompany Company { get; }
        ReadOnlyCollection<IDepartment> Departments { get; }
    }
    public interface IDepartment : IBaseRecord {
        string Title { get; }
        ICompany Company { get; }
        ReadOnlyCollection<IEmployee> Employees { get; }
    }
    private int _next_company = 1;
    private readonly Dictionary<int, Company> _company_pk = new Dictionary<int, Company>();
    private int _next_employee = 1;
    private readonly Dictionary<int, Employee> _employee_pk = new Dictionary<int, Employee>();
    private int _next_department = 1;
    private readonly Dictionary<int, Department> _department_pk = new Dictionary<int, Department>();
    private class Employee_Name_Comparer : IEqualityComparer<Employee> {
        public bool Equals(Employee x, Employee y) {
            if (!Object.Equals(x._name, y._name)) return false;
            return true;
        }
        public int GetHashCode(Employee obj) {
            int code = ((obj._name == null) ? 0 : obj._name.GetHashCode());
            return code;
        }
    }
    private readonly Dictionary<Employee, Employee> _employee_Name = new Dictionary<Employee, Employee>(new Employee_Name_Comparer());
    private class Department_Title_Comparer : IEqualityComparer<Department> {
        public bool Equals(Department x, Department y) {
            if (!Object.Equals(x._title, y._title)) return false;
            return true;
        }
        public int GetHashCode(Department obj) {
            int code = ((obj._title == null) ? 0 : obj._title.GetHashCode());
            return code;
        }
    }
    private readonly Dictionary<Department, Department> _department_Title = new Dictionary<Department, Department>(new Department_Title_Comparer());
    private class Company : ICompany, IDelRecord {
        public readonly int _id;
        public int Id { get { return _id; } }
        public Company(int id) {
            _id = id;
            _departments_Wrapper = _departments.AsReadOnly();
            _employees_Wrapper = _employees.AsReadOnly();
        }
        public ReadOnlyCollection<IDepartment> _departments_Wrapper;
        public readonly List<IDepartment> _departments = new List<IDepartment>();
        public ReadOnlyCollection<IDepartment> Departments {
            get { return _departments_Wrapper; }
        }
        public ReadOnlyCollection<IEmployee> _employees_Wrapper;
        public readonly List<IEmployee> _employees = new List<IEmployee>();
        public ReadOnlyCollection<IEmployee> Employees {
            get { return _employees_Wrapper; }
        }
        public virtual void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public virtual void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            db._company_pk.Remove(_id);
        }
        public virtual void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public virtual void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            foreach (Department _that_ in _departments) {
                _that_.PreDeleteOuter(deletionList, false);
            }
            foreach (Employee _that_ in _employees) {
                _that_.PreDeleteOuter(deletionList, false);
            }
        }
    }
    private class Employee : IEmployee, IDelRecord {
        public readonly int _id;
        public int Id { get { return _id; } }
        public Employee(int id) {
            _id = id;
            _departments_Wrapper = _departments.AsReadOnly();
        }
        public string _name;
        public string Name {
            get { return _name; }
        }
        public Company _company;
        public ICompany Company {
            get { return _company; }
        }
        public ReadOnlyCollection<IDepartment> _departments_Wrapper;
        public readonly List<IDepartment> _departments = new List<IDepartment>();
        public ReadOnlyCollection<IDepartment> Departments {
            get { return _departments_Wrapper; }
        }
        public virtual void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public virtual void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            if (_company != null ) {
                if ( !deletionList.Contains(_company)) {
                    _company._employees.Remove(this);
                }
            }
            foreach (Department _that_ in _departments) {
                if ( !deletionList.Contains(_that_)) {
                    _that_._employees.Remove(this);
                }
            }
            db._employee_Name.Remove(this);
            db._employee_pk.Remove(_id);
        }
        public virtual void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public virtual void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
    }
    private readonly Employee _employee_Key = new Employee(0);
    private class Department : IDepartment, IDelRecord {
        public readonly int _id;
        public int Id { get { return _id; } }
        public Department(int id) {
            _id = id;
            _employees_Wrapper = _employees.AsReadOnly();
        }
        public string _title;
        public string Title {
            get { return _title; }
        }
        public Company _company;
        public ICompany Company {
            get { return _company; }
        }
        public ReadOnlyCollection<IEmployee> _employees_Wrapper;
        public readonly List<IEmployee> _employees = new List<IEmployee>();
        public ReadOnlyCollection<IEmployee> Employees {
            get { return _employees_Wrapper; }
        }
        public virtual void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public virtual void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            if (_company != null ) {
                if ( !deletionList.Contains(_company)) {
                    _company._departments.Remove(this);
                }
            }
            foreach (Employee _that_ in _employees) {
                if ( !deletionList.Contains(_that_)) {
                    _that_._departments.Remove(this);
                }
            }
            db._department_Title.Remove(this);
            db._department_pk.Remove(_id);
        }
        public virtual void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public virtual void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
    }
    private readonly Department _department_Key = new Department(0);
    public ICompany InsertCompany(int id) {
        if ( id == 0 ) {
            id = _next_company;
        } else {
            if (_company_pk.ContainsKey(id)) {
                string className = _company_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_company ) {
            _next_company = id + 1;
        }
        var _record_ = new Company(id);
        _company_pk[id] = _record_;
        return _record_;
    }
    public ICompany GetCompany(int id) {
        Company _record_;
        if (!_company_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int CompanyCount() {
        return _company_pk.Count;
    }
    public IEnumerable<ICompany> EachCompany() {
        foreach (KeyValuePair<int, Company> record in _company_pk) {
            yield return record.Value;
        }
    }
    public void DeleteCompany(ICompany record) {
        if (record == null) return;
        Company _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_company_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Company' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public IEmployee InsertEmployee(int id, string name) {
        if ( id == 0 ) {
            id = _next_employee;
        } else {
            if (_employee_pk.ContainsKey(id)) {
                string className = _employee_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_employee ) {
            _next_employee = id + 1;
        }
        _employee_Key._name = name;
        if ( _employee_Name.ContainsKey(_employee_Key)) {
            throw new ArgumentException(
              "Fields 'Name' are not unique for 'Company'.");
        }
        var _record_ = new Employee(id);
        _record_._name = name;
        _employee_pk[id] = _record_;
        _employee_Name[_record_] = _record_;
        return _record_;
    }
    public IEmployee GetEmployee(int id) {
        Employee _record_;
        if (!_employee_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int EmployeeCount() {
        return _employee_pk.Count;
    }
    public IEnumerable<IEmployee> EachEmployee() {
        foreach (KeyValuePair<int, Employee> record in _employee_pk) {
            yield return record.Value;
        }
    }
    public void DeleteEmployee(IEmployee record) {
        if (record == null) return;
        Employee _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_employee_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Employee' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public IEmployee FindEmployeeByName(string name) {
        Employee _record_;
        _employee_Key._name = name;
        if (_employee_Name.TryGetValue(_employee_Key, out _record_)) {
            return _record_;
        } else {
            return null;
        }
    }
    public void SetEmployeeName(IEmployee record, string newValue) {
        Employee _record_;
        if ( !_employee_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Employee' with id '{0}' does not exist.",
                record.Id));
        }
        if (Object.Equals(_record_._name, newValue)) {
            return;
        }
        _employee_Key._name = newValue;
        if ( _employee_Name.ContainsKey(_employee_Key)) {
            throw new ArgumentException(
              "Fields 'Name' are not unique for 'Company'.");
        }
        _employee_Name.Remove(_record_);
        _record_._name = newValue;
        _employee_Name[_record_] = _record_;
    }
    public void SetEmployeeCompany(IEmployee record, ICompany newValue) {
        Employee _record_;
        if ( !_employee_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Employee' with id '{0}' does not exist.",
                record.Id));
        }
        if (Object.Equals(_record_._company, newValue)) {
            return;
        }
        Company _that_;
        if (newValue == null ) {
            _that_ = null;
        } else if (!_company_pk.TryGetValue(newValue.Id, out _that_)) {
            throw new ArgumentException(String.Format(
                "'Company' with id '{0}' does not exist.",
                newValue.Id));
        }
        if (_record_._company != null ) {
            _record_._company._employees.Remove(_record_);
        }
        _record_._company = _that_;
        if (_record_._company != null ) {
            _record_._company._employees.Add(_record_);
        }
    }
    public IDepartment InsertDepartment(int id, string title) {
        if ( id == 0 ) {
            id = _next_department;
        } else {
            if (_department_pk.ContainsKey(id)) {
                string className = _department_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_department ) {
            _next_department = id + 1;
        }
        _department_Key._title = title;
        if ( _department_Title.ContainsKey(_department_Key)) {
            throw new ArgumentException(
              "Fields 'Title' are not unique for 'Employee'.");
        }
        var _record_ = new Department(id);
        _record_._title = title;
        _department_pk[id] = _record_;
        _department_Title[_record_] = _record_;
        return _record_;
    }
    public IDepartment GetDepartment(int id) {
        Department _record_;
        if (!_department_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int DepartmentCount() {
        return _department_pk.Count;
    }
    public IEnumerable<IDepartment> EachDepartment() {
        foreach (KeyValuePair<int, Department> record in _department_pk) {
            yield return record.Value;
        }
    }
    public void DeleteDepartment(IDepartment record) {
        if (record == null) return;
        Department _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_department_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Department' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public IDepartment FindDepartmentByTitle(string title) {
        Department _record_;
        _department_Key._title = title;
        if (_department_Title.TryGetValue(_department_Key, out _record_)) {
            return _record_;
        } else {
            return null;
        }
    }
    public void SetDepartmentTitle(IDepartment record, string newValue) {
        Department _record_;
        if ( !_department_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Department' with id '{0}' does not exist.",
                record.Id));
        }
        if (Object.Equals(_record_._title, newValue)) {
            return;
        }
        _department_Key._title = newValue;
        if ( _department_Title.ContainsKey(_department_Key)) {
            throw new ArgumentException(
              "Fields 'Title' are not unique for 'Employee'.");
        }
        _department_Title.Remove(_record_);
        _record_._title = newValue;
        _department_Title[_record_] = _record_;
    }
    public void SetDepartmentCompany(IDepartment record, ICompany newValue) {
        Department _record_;
        if ( !_department_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Department' with id '{0}' does not exist.",
                record.Id));
        }
        if (Object.Equals(_record_._company, newValue)) {
            return;
        }
        Company _that_;
        if (newValue == null ) {
            _that_ = null;
        } else if (!_company_pk.TryGetValue(newValue.Id, out _that_)) {
            throw new ArgumentException(String.Format(
                "'Company' with id '{0}' does not exist.",
                newValue.Id));
        }
        if (_record_._company != null ) {
            _record_._company._departments.Remove(_record_);
        }
        _record_._company = _that_;
        if (_record_._company != null ) {
            _record_._company._departments.Add(_record_);
        }
    }
    public void AddToDepartmentEmployees(IDepartment left, IEmployee right) {
        Department _left_;
        Employee _right_;
        if (left == null || right == null) return;
        if ( !_department_pk.TryGetValue(left.Id, out _left_)) {
            throw new ArgumentException(String.Format(
                "'Department' with id '{0}' does not exist.",
                left.Id));
        }
        if ( !_employee_pk.TryGetValue(right.Id, out _right_)) {
            throw new ArgumentException(String.Format(
                "'Employee' with id '{0}' does not exist.",
                right.Id));
        }
        _left_._employees.Add(_right_);
        _right_._departments.Add(_left_);
    }
    public void RemoveFromDepartmentEmployees(IDepartment left, IEmployee right) {
        Department _left_;
        Employee _right_;
        if (left == null || right == null) return;
        if ( !_department_pk.TryGetValue(left.Id, out _left_)) {
            throw new ArgumentException(String.Format(
                "'Department' with id '{0}' does not exist.",
                left.Id));
        }
        if ( !_employee_pk.TryGetValue(right.Id, out _right_)) {
            throw new ArgumentException(String.Format(
                "'Employee' with id '{0}' does not exist.",
                right.Id));
        }
        _left_._employees.Remove(_right_);
        _right_._departments.Remove(_left_);
    }

    public static void Equal(object expected, object actual) {
        // item 323
        //PutObj(expected);
        //PutObj(actual);
        //Put("\n");
        // item 280
        if (Object.Equals(expected, actual)) {
            
        } else {
            // item 262
            if (expected is System.Collections.IEnumerable) {
                // item 268
                if (actual is System.Collections.IEnumerable) {
                    // item 271
                    var expectedEn = (System.Collections.IEnumerable)expected;
                    var actualEn = (System.Collections.IEnumerable)actual;
                    // item 282
                    List<object> exList = expectedEn.Cast<object>().ToList();
                    List<object> acList = actualEn.Cast<object>().ToList();
                    // item 272
                    if (exList.Count == acList.Count) {
                        // item 2750001
                        int i = 0;
                        while (true) {
                            // item 2750002
                            if (i < exList.Count) {
                                
                            } else {
                                break;
                            }
                            // item 277
                            Equal(exList[i], acList[i]);
                            // item 2750003
                            i++;
                        }
                    } else {
                        // item 324
                        string message = 
                        String.Format("Collections have different sizes: expected={0}, actual={1}", 
                        	exList.Count, acList.Count);
                        // item 274
                        throw new Exception(message);
                    }
                } else {
                    // item 270
                    throw new Exception("Both should be IEnumerable");
                }
            } else {
                // item 265
                if (actual is System.Collections.IEnumerable) {
                    // item 266
                    throw new Exception("Both should be IEnumerable");
                } else {
                    // item 278
                    throw new Exception("Objects are not equal.");
                }
            }
        }
    }

    public static void ExpectException(AnyCode code) {
        // item 297
        bool caught = false;
        try {
            code();
        }
        catch {
            caught = true;
        }
        // item 298
        if (caught) {
            
        } else {
            // item 301
            throw new Exception("Exception expected but not thrown.");
        }
    }

    public static void Main() {
        // item 251
        Bar db = new Bar();
        // item 252
        Bar.IDepartment yellow_m = db.InsertDepartment(0, "Yellow marketing");
        Bar.IDepartment grey_m = db.InsertDepartment(0, "Grey marketing");
        // item 253
        Bar.IEmployee mark = db.InsertEmployee(10, "Mark");
        Bar.IEmployee john = db.InsertEmployee(20, "John");
        Bar.IEmployee scott = db.InsertEmployee(30, "Scott");
        // item 188
        db.AddToDepartmentEmployees(yellow_m, mark);
        // item 238
        db.AddToDepartmentEmployees(yellow_m, null);
        // item 213
        var fake = new FakeEmployee{ Id = 800, Name = "fake" };
        ExpectException(() =>  db.AddToDepartmentEmployees(yellow_m, fake));
        // item 212
        db.AddToDepartmentEmployees(grey_m, mark);
        db.AddToDepartmentEmployees(grey_m, john);
        db.AddToDepartmentEmployees(grey_m, scott);
        // item 254
        var grey_employees = (
        	from e in grey_m.Employees 
        	select e.Id).ToList();
        var yellow_employees = (
        	from e in yellow_m.Employees
        	select e.Id).ToList();
        
        grey_employees.Sort();
        yellow_employees.Sort();
        // item 255
        Equal(new int[] {10, 20, 30}, grey_employees);
        Equal(new int[] {10}, yellow_employees);
        // item 256
        Equal(new Bar.IDepartment[] {yellow_m, grey_m}, mark.Departments);
        Equal(new Bar.IDepartment[] {grey_m}, john.Departments);
        Equal(new Bar.IDepartment[] {grey_m}, scott.Departments);
        // item 227
        Bar.ICompany company = db.InsertCompany(800);
        // item 228
        db.SetEmployeeCompany(mark, company);
        db.SetEmployeeCompany(john, company);
        db.SetEmployeeCompany(scott, company);
        // item 302
        db.SetDepartmentCompany(grey_m, company);
        db.SetDepartmentCompany(yellow_m, company);
        // item 230
        db.RemoveFromDepartmentEmployees(yellow_m, mark);
        // item 231
        db.RemoveFromDepartmentEmployees(grey_m, mark);
        db.RemoveFromDepartmentEmployees(grey_m, john);
        db.RemoveFromDepartmentEmployees(grey_m, scott);
        // item 232
        Equal(0, grey_m.Employees.Count);
        Equal(0, yellow_m.Employees.Count);
        // item 233
        Equal(0, mark.Departments.Count);
        Equal(0, john.Departments.Count);
        Equal(0, scott.Departments.Count);
        // item 234
        db.AddToDepartmentEmployees(yellow_m, john);
        // item 303
        db.AddToDepartmentEmployees(grey_m, mark);
        db.AddToDepartmentEmployees(grey_m, john);
        db.AddToDepartmentEmployees(grey_m, scott);
        // item 236
        Equal(new Bar.IEmployee[] {mark, john, scott}, grey_m.Employees);
        Equal(new Bar.IEmployee[] {john}, yellow_m.Employees);
        // item 237
        Equal(new Bar.IDepartment[] {yellow_m, grey_m}, john.Departments);
        Equal(new Bar.IDepartment[] {grey_m}, mark.Departments);
        Equal(new Bar.IDepartment[] {grey_m}, scott.Departments);
        // item 239
        db.DeleteEmployee(scott);
        // item 240
        Equal(new Bar.IEmployee[] {mark, john}, grey_m.Employees);
        // item 241
        db.DeleteDepartment(yellow_m);
        // item 242
        Equal(new Bar.IDepartment[] {grey_m}, john.Departments);
        // item 243
        db.DeleteCompany(company);
        // item 244
        Equal(0, db.EmployeeCount());
        Equal(0, db.DepartmentCount());
    }

    public static void NotEqual(object left, object right) {
        // item 288
        if (Object.Equals(left, right)) {
            // item 291
            throw new Exception("Objects are equal.");
        } else {
            
        }
    }

    public static void Put(string format, params object[] args) {
        // item 309
        System.Console.WriteLine(format, args);
    }

    public static void PutObj(object obj) {
        // item 317
        IBaseRecord rec = obj as IBaseRecord;
        // item 319
        if (rec == null) {
            // item 322
            Put("{0}", obj);
        } else {
            // item 318
            Console.WriteLine("{0} {1}", rec.GetType().Name, rec.Id);
        }
    }
}

