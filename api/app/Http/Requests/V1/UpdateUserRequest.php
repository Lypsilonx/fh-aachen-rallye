<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdateUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $method = $this->method();

        if ($method === 'PUT') {
            return [
                'username' => ['required', 'string', 'max:255'],
                'points' => ['required', 'integer', 'min:0'],
                'challengeStates' => ['required', 'string'],
                'displayName' => ['string', 'nullable'],
            ];
        } else {
            return [
                'username' => ['sometimes', 'required', 'string', 'max:255'],
                'points' => ['sometimes', 'required', 'integer', 'min:0'],
                'challengeStates' => ['sometimes', 'required', 'string'],
                'displayName' => ['sometimes', 'string', 'nullable'],
            ];
        }
    }
}
