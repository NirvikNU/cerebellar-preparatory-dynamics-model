function appliedTorque = apply_arm_torque_safety(rawTorque, plant)
    if plant.useHardSafetyClipping
        safetyLimit = single(plant.hardTorqueSafetyLimitNm);
        appliedTorque = min(max(rawTorque, -safetyLimit), safetyLimit);
    else
        appliedTorque = rawTorque;
    end
end
