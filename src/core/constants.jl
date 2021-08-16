"Enumerated type specifying the status of the component."
@enum STATUS begin
    STATUS_UNKNOWN = -1 # The status of the component is unknown (i.e., on or off).
    STATUS_INACTIVE = 0 # The status of the component is inactive (i.e., off or removed).
    STATUS_ACTIVE = 1 # The status of the component is active (i.e., on or present).
end

"Ensures that JSON serialization of `STATUS` returns an integer."
JSON.lower(x::STATUS) = Int(x)