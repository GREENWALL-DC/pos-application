exports.validateCustomer =(data)=>{
    const errors =[];

    if(!data.name)errors.push("Customer name is required");

    if(!data.phone)errors.push("Phone number is required");

    if (!data.tin) errors.push("TIN is required");

    return errors;
};