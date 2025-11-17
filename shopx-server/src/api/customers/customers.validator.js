exports.validateCustomer =(data)=>{
    const errors =[];

    if(!data.name)errors.push("Customer name is required");

    if(!data.phone)errors.push("Phone number is required");

    if(!data.gst_number)errors.push("Gst number is required");

    return errors;
};